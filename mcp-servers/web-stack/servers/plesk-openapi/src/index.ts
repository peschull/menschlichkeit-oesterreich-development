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
import SwaggerParser from "swagger-parser";
import yaml from "js-yaml";
import { z } from "zod";

// Plesk API Client Configuration Schema
const PleskConfigSchema = z.object({
  host: z.string(),
  port: z.number().default(8443),
  username: z.string(),
  password: z.string(),
  apiKey: z.string().optional(),
  secure: z.boolean().default(true),
  timeout: z.number().default(30000)
});

type PleskConfig = z.infer<typeof PleskConfigSchema>;

class PleskMCPServer {
  private server: Server;
  private apiClient: AxiosInstance | null = null;
  private config: PleskConfig | null = null;
  private openApiSpec: any = null;

  constructor() {
    this.server = new Server(
      {
        name: "plesk-openapi-server",
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
            uri: "plesk://api/spec",
            name: "Plesk OpenAPI Specification",
            description: "Current Plesk OpenAPI/Swagger specification",
            mimeType: "application/yaml",
          },
          {
            uri: "plesk://api/endpoints",
            name: "Available API Endpoints",
            description: "List of all available Plesk API endpoints",
            mimeType: "application/json",
          }
        ],
      };
    });

    // Read resources
    this.server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
      const { uri } = request.params;

      if (uri === "plesk://api/spec") {
        if (!this.openApiSpec) {
          await this.loadOpenApiSpec();
        }
        return {
          contents: [
            {
              uri,
              mimeType: "application/yaml",
              text: yaml.dump(this.openApiSpec),
            },
          ],
        };
      }

      if (uri === "plesk://api/endpoints") {
        if (!this.openApiSpec) {
          await this.loadOpenApiSpec();
        }
        
        const endpoints = this.extractEndpoints();
        return {
          contents: [
            {
              uri,
              mimeType: "application/json",
              text: JSON.stringify(endpoints, null, 2),
            },
          ],
        };
      }

      throw new McpError(ErrorCode.InvalidRequest, `Unknown resource: ${uri}`);
    });

    // List available tools
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: "plesk_configure",
            description: "Configure Plesk API connection",
            inputSchema: {
              type: "object",
              properties: {
                host: { type: "string", description: "Plesk server hostname or IP" },
                port: { type: "number", default: 8443 },
                username: { type: "string", description: "Plesk admin username" },
                password: { type: "string", description: "Plesk admin password" },
                apiKey: { type: "string", description: "API key (optional, alternative to username/password)" },
                secure: { type: "boolean", default: true, description: "Use HTTPS" }
              },
              required: ["host", "username", "password"],
            },
          },
          {
            name: "plesk_api_call",
            description: "Make authenticated API call to Plesk",
            inputSchema: {
              type: "object",
              properties: {
                endpoint: { type: "string", description: "API endpoint path (e.g., /api/v2/domains)" },
                method: { type: "string", enum: ["GET", "POST", "PUT", "DELETE", "PATCH"], default: "GET" },
                data: { type: "object", description: "Request body data" },
                params: { type: "object", description: "Query parameters" }
              },
              required: ["endpoint"],
            },
          },
          {
            name: "plesk_list_domains",
            description: "List all domains in Plesk",
            inputSchema: {
              type: "object",
              properties: {
                limit: { type: "number", default: 50 },
                offset: { type: "number", default: 0 }
              }
            },
          },
          {
            name: "plesk_domain_info",
            description: "Get detailed information about a specific domain",
            inputSchema: {
              type: "object",
              properties: {
                domain: { type: "string", description: "Domain name" }
              },
              required: ["domain"],
            },
          },
          {
            name: "plesk_list_customers",
            description: "List all customers in Plesk",
            inputSchema: {
              type: "object",
              properties: {
                limit: { type: "number", default: 50 },
                offset: { type: "number", default: 0 }
              }
            },
          },
          {
            name: "plesk_create_domain",
            description: "Create a new domain in Plesk",
            inputSchema: {
              type: "object",
              properties: {
                name: { type: "string", description: "Domain name" },
                customer: { type: "string", description: "Customer login or ID" },
                hosting_type: { type: "string", enum: ["virtual_hosting", "standard_forwarding", "frame_forwarding"], default: "virtual_hosting" },
                document_root: { type: "string", description: "Document root path (optional)" }
              },
              required: ["name", "customer"],
            },
          }
        ],
      };
    });

    // Handle tool calls
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      try {
        switch (name) {
          case "plesk_configure":
            return await this.configurePlesk(args);

          case "plesk_api_call":
            return await this.makeApiCall(args);

          case "plesk_list_domains":
            return await this.listDomains(args);

          case "plesk_domain_info":
            return await this.getDomainInfo(args);

          case "plesk_list_customers":
            return await this.listCustomers(args);

          case "plesk_create_domain":
            return await this.createDomain(args);

          default:
            throw new McpError(ErrorCode.MethodNotFound, `Unknown tool: ${name}`);
        }
      } catch (error) {
        const errorMessage = error instanceof Error ? error.message : "Unknown error";
        throw new McpError(ErrorCode.InternalError, `Tool execution failed: ${errorMessage}`);
      }
    });
  }

  private async configurePlesk(args: any) {
    try {
      this.config = PleskConfigSchema.parse(args);
      
      const protocol = this.config.secure ? "https" : "http";
      const baseURL = `${protocol}://${this.config.host}:${this.config.port}`;
      
      this.apiClient = axios.create({
        baseURL,
        timeout: this.config.timeout,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        auth: this.config.apiKey 
          ? undefined 
          : {
              username: this.config.username,
              password: this.config.password,
            },
      });

      if (this.config.apiKey) {
        this.apiClient.defaults.headers.common["X-API-Key"] = this.config.apiKey;
      }

      // Test connection
      await this.apiClient.get("/api/v2/server");
      
      // Load OpenAPI spec
      await this.loadOpenApiSpec();

      return {
        content: [
          {
            type: "text",
            text: `Successfully configured Plesk API connection to ${baseURL}`
          }
        ]
      };
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : "Configuration failed";
      return {
        content: [
          {
            type: "text",
            text: `Failed to configure Plesk API: ${errorMessage}`
          }
        ]
      };
    }
  }

  private async loadOpenApiSpec() {
    if (!this.config || !this.apiClient) {
      throw new Error("Plesk API not configured");
    }

    try {
      const response = await this.apiClient.get("/api/v2/swagger.yml");
      this.openApiSpec = yaml.load(response.data);
    } catch (error) {
      // Fallback to JSON if YAML fails
      try {
        const response = await this.apiClient.get("/api/v2/swagger.json");
        this.openApiSpec = response.data;
      } catch (jsonError) {
        throw new Error("Failed to load OpenAPI specification from Plesk");
      }
    }
  }

  private extractEndpoints() {
    if (!this.openApiSpec || !this.openApiSpec.paths) {
      return [];
    }

    const endpoints = [];
    for (const [path, methods] of Object.entries(this.openApiSpec.paths)) {
      for (const [method, details] of Object.entries(methods as any)) {
        if (typeof details === "object" && details !== null) {
          endpoints.push({
            path,
            method: method.toUpperCase(),
            summary: (details as any).summary || "",
            description: (details as any).description || "",
            operationId: (details as any).operationId || "",
          });
        }
      }
    }
    return endpoints;
  }

  private async makeApiCall(args: any) {
    if (!this.apiClient) {
      throw new Error("Plesk API not configured. Run plesk_configure first.");
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

  private async listDomains(args: any) {
    const { limit = 50, offset = 0 } = args;
    return await this.makeApiCall({
      endpoint: "/api/v2/domains",
      method: "GET",
      params: { limit, offset }
    });
  }

  private async getDomainInfo(args: any) {
    const { domain } = args;
    return await this.makeApiCall({
      endpoint: `/api/v2/domains/${encodeURIComponent(domain)}`,
      method: "GET"
    });
  }

  private async listCustomers(args: any) {
    const { limit = 50, offset = 0 } = args;
    return await this.makeApiCall({
      endpoint: "/api/v2/customers",
      method: "GET",
      params: { limit, offset }
    });
  }

  private async createDomain(args: any) {
    const { name, customer, hosting_type = "virtual_hosting", document_root } = args;
    
    const domainData: any = {
      name,
      customer,
      hosting_type
    };

    if (document_root) {
      domainData.document_root = document_root;
    }

    return await this.makeApiCall({
      endpoint: "/api/v2/domains",
      method: "POST",
      data: domainData
    });
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error("Plesk OpenAPI MCP server running on stdio");
  }
}

const server = new PleskMCPServer();
server.run().catch(console.error);