import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ErrorCode,
  ListResourcesRequestSchema,
  ListToolsRequestSchema,
  McpError,
  ReadResourceRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import axios, { AxiosInstance } from "axios";
import mysql from "mysql2/promise";
import { z } from "zod";
import * as fs from "fs";
import * as path from "path";

// Laravel Configuration Schema
const LaravelConfigSchema = z.object({
  projectPath: z.string(),
  apiUrl: z.string().url().optional(),
  apiToken: z.string().optional(),
  database: z.object({
    host: z.string().default("localhost"),
    port: z.number().default(3306),
    user: z.string(),
    password: z.string(),
    database: z.string()
  }).optional(),
  timeout: z.number().default(30000)
});

type LaravelConfig = z.infer<typeof LaravelConfigSchema>;

class LaravelMCPServer {
  private server: Server;
  private apiClient: AxiosInstance | null = null;
  private dbConnection: mysql.Connection | null = null;
  private config: LaravelConfig | null = null;

  constructor() {
    this.server = new Server(
      {
        name: "laravel-integration-server",
        version: "1.0.0",
      },
      {
        capabilities: {
          resources: {},
          tools: {},
        },
      }
    );

    this.setupHandlers();
  }

  private setupHandlers() {
    // List available resources
    this.server.setRequestHandler(ListResourcesRequestSchema, async () => {
      return {
        resources: [
          {
            uri: "laravel://project/structure",
            name: "Laravel Project Structure",
            description: "Overview of Laravel project structure and key files",
            mimeType: "application/json",
          },
          {
            uri: "laravel://routes/list",
            name: "Application Routes",
            description: "List of all registered routes",
            mimeType: "application/json",
          },
          {
            uri: "laravel://models/list",
            name: "Eloquent Models",
            description: "List of all Eloquent models",
            mimeType: "application/json",
          },
          {
            uri: "laravel://config/app",
            name: "Application Configuration",
            description: "Laravel application configuration",
            mimeType: "application/json",
          }
        ],
      };
    });

    // Read resources
    this.server.setRequestHandler(ReadResourceRequestSchema, async (request: any) => {
      const { uri } = request.params;

      switch (uri) {
        case "laravel://project/structure":
          const structure = await this.getProjectStructure();
          return {
            contents: [
              {
                uri,
                mimeType: "application/json",
                text: JSON.stringify(structure, null, 2),
              },
            ],
          };

        case "laravel://routes/list":
          const routes = await this.getRoutes();
          return {
            contents: [
              {
                uri,
                mimeType: "application/json",
                text: JSON.stringify(routes, null, 2),
              },
            ],
          };

        case "laravel://models/list":
          const models = await this.getModels();
          return {
            contents: [
              {
                uri,
                mimeType: "application/json",
                text: JSON.stringify(models, null, 2),
              },
            ],
          };

        case "laravel://config/app":
          const config = await this.getAppConfig();
          return {
            contents: [
              {
                uri,
                mimeType: "application/json",
                text: JSON.stringify(config, null, 2),
              },
            ],
          };

        default:
          throw new McpError(ErrorCode.InvalidRequest, `Unknown resource: ${uri}`);
      }
    });

    // List available tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: "laravel_configure",
            description: "Configure Laravel project connection",
            inputSchema: {
              type: "object",
              properties: {
                projectPath: { type: "string", description: "Path to Laravel project root" },
                apiUrl: { type: "string", format: "uri", description: "Laravel API base URL" },
                apiToken: { type: "string", description: "API authentication token" },
                database: {
                  type: "object",
                  properties: {
                    host: { type: "string", default: "localhost" },
                    port: { type: "number", default: 3306 },
                    user: { type: "string" },
                    password: { type: "string" },
                    database: { type: "string" }
                  },
                  required: ["user", "password", "database"],
                  description: "Database connection configuration"
                }
              },
              required: ["projectPath"],
            },
          },
          {
            name: "laravel_artisan",
            description: "Execute Laravel Artisan commands",
            inputSchema: {
              type: "object",
              properties: {
                command: { type: "string", description: "Artisan command to execute (e.g., 'migrate', 'make:model User')" },
                options: { type: "array", items: { type: "string" }, description: "Command options/flags" },
                workingDir: { type: "string", description: "Working directory (defaults to project path)" }
              },
              required: ["command"],
            },
          },
          {
            name: "laravel_make_model",
            description: "Generate a new Eloquent model",
            inputSchema: {
              type: "object",
              properties: {
                name: { type: "string", description: "Model name" },
                migration: { type: "boolean", default: false, description: "Create migration file" },
                factory: { type: "boolean", default: false, description: "Create factory file" },
                controller: { type: "boolean", default: false, description: "Create controller file" },
                resource: { type: "boolean", default: false, description: "Create resource controller" },
                api: { type: "boolean", default: false, description: "Create API controller" }
              },
              required: ["name"],
            },
          },
          {
            name: "laravel_make_controller",
            description: "Generate a new controller",
            inputSchema: {
              type: "object",
              properties: {
                name: { type: "string", description: "Controller name" },
                resource: { type: "boolean", default: false, description: "Create resource controller" },
                api: { type: "boolean", default: false, description: "Create API controller" },
                model: { type: "string", description: "Associated model name" }
              },
              required: ["name"],
            },
          },
          {
            name: "laravel_make_migration",
            description: "Generate a new database migration",
            inputSchema: {
              type: "object",
              properties: {
                name: { type: "string", description: "Migration name" },
                create: { type: "string", description: "Table name to create" },
                table: { type: "string", description: "Table name to modify" }
              },
              required: ["name"],
            },
          },
          {
            name: "laravel_run_migration",
            description: "Run database migrations",
            inputSchema: {
              type: "object",
              properties: {
                step: { type: "number", description: "Number of migrations to run" },
                rollback: { type: "boolean", default: false, description: "Rollback migrations" },
                fresh: { type: "boolean", default: false, description: "Drop all tables and re-run migrations" },
                seed: { type: "boolean", default: false, description: "Seed database after migration" }
              }
            },
          },
          {
            name: "laravel_tinker",
            description: "Execute PHP code in Laravel's Tinker environment",
            inputSchema: {
              type: "object",
              properties: {
                code: { type: "string", description: "PHP code to execute" }
              },
              required: ["code"],
            },
          },
          {
            name: "laravel_db_query",
            description: "Execute database query using configured connection",
            inputSchema: {
              type: "object",
              properties: {
                query: { type: "string", description: "SQL query to execute" },
                params: { type: "array", items: { type: "string" }, description: "Query parameters" }
              },
              required: ["query"],
            },
          },
          {
            name: "laravel_api_call",
            description: "Make API call to Laravel application",
            inputSchema: {
              type: "object",
              properties: {
                endpoint: { type: "string", description: "API endpoint path" },
                method: { type: "string", enum: ["GET", "POST", "PUT", "DELETE", "PATCH"], default: "GET" },
                data: { type: "object", description: "Request body data" },
                params: { type: "object", description: "Query parameters" }
              },
              required: ["endpoint"],
            },
          },
          {
            name: "laravel_clear_cache",
            description: "Clear Laravel application caches",
            inputSchema: {
              type: "object",
              properties: {
                type: { 
                  type: "string", 
                  enum: ["all", "config", "route", "view", "cache", "compiled"],
                  default: "all",
                  description: "Type of cache to clear" 
                }
              }
            },
          }
        ],
      };
    });

    // Handle tool calls
    this.server.setRequestHandler(CallToolRequestSchema, async (request: any) => {
      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case "laravel_configure":
            return await this.configure(args);
          case "laravel_artisan":
            return await this.runArtisan(args);
          case "laravel_make_model":
            return await this.makeModel(args);
          case "laravel_make_controller":
            return await this.makeController(args);
          case "laravel_make_migration":
            return await this.makeMigration(args);
          case "laravel_run_migration":
            return await this.runMigration(args);
          case "laravel_tinker":
            return await this.runTinker(args);
          case "laravel_db_query":
            return await this.runDbQuery(args);
          case "laravel_api_call":
            return await this.makeApiCall(args);
          case "laravel_clear_cache":
            return await this.clearCache(args);
          default:
            throw new McpError(ErrorCode.MethodNotFound, `Unknown tool: ${name}`);
        }
      } catch (error) {
        const errorMessage = error instanceof Error ? error.message : "Unknown error";
        throw new McpError(ErrorCode.InternalError, `Tool execution failed: ${errorMessage}`);
      }
    });
  }

  private async configure(args: any) {
    try {
      this.config = LaravelConfigSchema.parse(args);

      // Verify Laravel project path
      const composerPath = path.join(this.config.projectPath, "composer.json");
      if (!fs.existsSync(composerPath)) {
        throw new Error("Invalid Laravel project path: composer.json not found");
      }

      const artisanPath = path.join(this.config.projectPath, "artisan");
      if (!fs.existsSync(artisanPath)) {
        throw new Error("Invalid Laravel project path: artisan file not found");
      }

      // Set up API client if URL provided
      if (this.config.apiUrl) {
        this.apiClient = axios.create({
          baseURL: this.config.apiUrl,
          timeout: this.config.timeout,
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
        });

        if (this.config.apiToken) {
          this.apiClient.defaults.headers.common["Authorization"] = `Bearer ${this.config.apiToken}`;
        }
      }

      // Set up database connection if provided
      if (this.config.database) {
        this.dbConnection = await mysql.createConnection(this.config.database);
      }

      return {
        content: [
          {
            type: "text",
            text: `Successfully configured Laravel project at ${this.config.projectPath}\nAPI: ${this.config.apiUrl || 'Not configured'}\nDatabase: ${this.config.database ? 'Connected' : 'Not configured'}`
          }
        ]
      };
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : "Configuration failed";
      return {
        content: [
          {
            type: "text",
            text: `Failed to configure Laravel: ${errorMessage}`
          }
        ]
      };
    }
  }

  private async runArtisan(args: any): Promise<any> {
    if (!this.config) {
      throw new Error("Laravel not configured. Run laravel_configure first.");
    }

    const { command, options = [], workingDir } = args;
    const { spawn } = require("child_process");

    return new Promise<any>((resolve) => {
      const cwd = workingDir || this.config!.projectPath;
      const phpPath = process.platform === "win32" ? "php.exe" : "php";
      const artisanArgs = ["artisan", command, ...options];

      const artisan = spawn(phpPath, artisanArgs, {
        cwd,
        stdio: "pipe"
      });

      let output = "";
      let error = "";

      artisan.stdout.on("data", (data: Buffer) => {
        output += data.toString();
      });

      artisan.stderr.on("data", (data: Buffer) => {
        error += data.toString();
      });

      artisan.on("close", (code: number) => {
        resolve({
          content: [
            {
              type: "text",
              text: `Artisan command: php artisan ${command} ${options.join(' ')}\nExit code: ${code}\n\nOutput:\n${output}\n\nError:\n${error}`
            }
          ]
        });
      });
    });
  }

  private async makeModel(args: any) {
    const { name, migration, factory, controller, resource, api } = args;
    const options = [];

    if (migration) options.push("--migration");
    if (factory) options.push("--factory");
    if (controller) options.push("--controller");
    if (resource) options.push("--resource");
    if (api) options.push("--api");

    return await this.runArtisan({
      command: `make:model ${name}`,
      options
    });
  }

  private async makeController(args: any) {
    const { name, resource, api, model } = args;
    const options = [];

    if (resource) options.push("--resource");
    if (api) options.push("--api");
    if (model) options.push(`--model=${model}`);

    return await this.runArtisan({
      command: `make:controller ${name}`,
      options
    });
  }

  private async makeMigration(args: any) {
    const { name, create, table } = args;
    const options = [];

    if (create) options.push(`--create=${create}`);
    if (table) options.push(`--table=${table}`);

    return await this.runArtisan({
      command: `make:migration ${name}`,
      options
    });
  }

  private async runMigration(args: any) {
    const { step, rollback, fresh, seed } = args;
    let command = "migrate";
    const options = [];

    if (rollback) command = "migrate:rollback";
    if (fresh) command = "migrate:fresh";
    if (step) options.push(`--step=${step}`);
    if (seed) options.push("--seed");

    return await this.runArtisan({
      command,
      options
    });
  }

  private async runTinker(args: any) {
    const { code } = args;
    // This is a simplified implementation - in practice, you'd want to handle this more carefully
    return await this.runArtisan({
      command: "tinker",
      options: ["--execute", code]
    });
  }

  private async runDbQuery(args: any) {
    if (!this.dbConnection) {
      throw new Error("Database not configured. Include database configuration in laravel_configure.");
    }

    const { query, params = [] } = args;

    try {
      const [rows] = await this.dbConnection.execute(query, params);
      
      return {
        content: [
          {
            type: "text",
            text: `Query executed successfully:\n${query}\n\nResults:\n${JSON.stringify(rows, null, 2)}`
          }
        ]
      };
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : "Database query failed";
      return {
        content: [
          {
            type: "text",
            text: `Database query failed: ${errorMessage}\nQuery: ${query}`
          }
        ]
      };
    }
  }

  private async makeApiCall(args: any) {
    if (!this.apiClient) {
      throw new Error("API not configured. Include apiUrl in laravel_configure.");
    }

    const { endpoint, method = "GET", data, params } = args;

    try {
      const response = await this.apiClient.request({
        url: endpoint,
        method: method.toUpperCase(),
        data,
        params,
      });

      return {
        content: [
          {
            type: "text",
            text: JSON.stringify(response.data, null, 2)
          }
        ]
      };
    } catch (error) {
      if (axios.isAxiosError(error)) {
        return {
          content: [
            {
              type: "text",
              text: `API call failed: ${error.response?.status} ${error.response?.statusText}\n${JSON.stringify(error.response?.data, null, 2)}`
            }
          ]
        };
      }
      throw error;
    }
  }

  private async clearCache(args: any) {
    const { type = "all" } = args;
    
    const commands: { [key: string]: string } = {
      all: "optimize:clear",
      config: "config:clear",
      route: "route:clear", 
      view: "view:clear",
      cache: "cache:clear",
      compiled: "clear-compiled"
    };

    const command = commands[type] || commands.all;
    
    return await this.runArtisan({
      command
    });
  }

  private async getProjectStructure() {
    if (!this.config) {
      throw new Error("Laravel not configured");
    }

    // Read composer.json for project info
    const composerPath = path.join(this.config.projectPath, "composer.json");
    const composer = JSON.parse(fs.readFileSync(composerPath, "utf8"));

    return {
      name: composer.name || "Laravel Project",
      version: composer.version || "unknown",
      description: composer.description || "",
      dependencies: composer.require || {},
      devDependencies: composer["require-dev"] || {},
      structure: {
        app: "Application logic",
        bootstrap: "Framework bootstrap files",
        config: "Configuration files",
        database: "Database migrations, factories, seeds",
        public: "Web server document root",
        resources: "Views, assets, language files",
        routes: "Route definitions",
        storage: "Generated files, logs, cache",
        tests: "Test files",
        vendor: "Composer dependencies"
      }
    };
  }

  private async getRoutes() {
    if (!this.config) {
      throw new Error("Laravel not configured");
    }

    // This would typically run `php artisan route:list` and parse the output
    return await this.runArtisan({
      command: "route:list",
      options: ["--json"]
    });
  }

  private async getModels() {
    if (!this.config) {
      throw new Error("Laravel not configured");
    }

    const modelsPath = path.join(this.config.projectPath, "app", "Models");
    const models = [];

    try {
      if (fs.existsSync(modelsPath)) {
        const files = fs.readdirSync(modelsPath);
        for (const file of files) {
          if (file.endsWith(".php")) {
            models.push({
              name: file.replace(".php", ""),
              path: path.join(modelsPath, file)
            });
          }
        }
      }
    } catch (error) {
      // Models directory might not exist
    }

    return models;
  }

  private async getAppConfig() {
    if (!this.config) {
      throw new Error("Laravel not configured");
    }

    try {
      const configPath = path.join(this.config.projectPath, "config", "app.php");
      if (fs.existsSync(configPath)) {
        // This is simplified - in practice, you'd parse PHP config file
        return {
          note: "PHP config file found",
          path: configPath
        };
      }
    } catch (error) {
      // Config file might not be accessible
    }

    return { error: "Could not read application configuration" };
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error("Laravel Integration MCP server running on stdio");
  }
}

const server = new LaravelMCPServer();
server.run().catch(console.error);