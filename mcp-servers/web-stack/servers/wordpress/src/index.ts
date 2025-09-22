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
import FormData from "form-data";
import { z } from "zod";

// WordPress Configuration Schema
const WordPressConfigSchema = z.object({
  siteUrl: z.string().url(),
  username: z.string(),
  password: z.string().optional(),
  applicationPassword: z.string().optional(),
  jwtToken: z.string().optional(),
  timeout: z.number().default(30000)
});

type WordPressConfig = z.infer<typeof WordPressConfigSchema>;

class WordPressMCPServer {
  private server: Server;
  private apiClient: AxiosInstance | null = null;
  private config: WordPressConfig | null = null;
  private siteInfo: any = null;

  constructor() {
    this.server = new Server(
      {
        name: "wordpress-rest-api-server",
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
            uri: "wordpress://site/info",
            name: "WordPress Site Information",
            description: "Basic information about the WordPress site",
            mimeType: "application/json",
          },
          {
            uri: "wordpress://posts/recent",
            name: "Recent Posts",
            description: "List of recent posts",
            mimeType: "application/json",
          },
          {
            uri: "wordpress://pages/all",
            name: "All Pages",
            description: "List of all pages",
            mimeType: "application/json",
          },
          {
            uri: "wordpress://media/recent",
            name: "Recent Media",
            description: "List of recent media files",
            mimeType: "application/json",
          }
        ],
      };
    });

    // Read resources
    this.server.setRequestHandler(ReadResourceRequestSchema, async (request: any) => {
      const { uri } = request.params;

      switch (uri) {
        case "wordpress://site/info":
          if (!this.siteInfo) {
            await this.loadSiteInfo();
          }
          return {
            contents: [
              {
                uri,
                mimeType: "application/json",
                text: JSON.stringify(this.siteInfo, null, 2),
              },
            ],
          };

        case "wordpress://posts/recent":
          const posts = await this.getPosts({ per_page: 10 });
          return {
            contents: [
              {
                uri,
                mimeType: "application/json",
                text: JSON.stringify(posts, null, 2),
              },
            ],
          };

        case "wordpress://pages/all":
          const pages = await this.getPages({});
          return {
            contents: [
              {
                uri,
                mimeType: "application/json",
                text: JSON.stringify(pages, null, 2),
              },
            ],
          };

        case "wordpress://media/recent":
          const media = await this.getMedia({ per_page: 10 });
          return {
            contents: [
              {
                uri,
                mimeType: "application/json",
                text: JSON.stringify(media, null, 2),
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
            name: "wordpress_configure",
            description: "Configure WordPress REST API connection",
            inputSchema: {
              type: "object",
              properties: {
                siteUrl: { type: "string", format: "uri", description: "WordPress site URL" },
                username: { type: "string", description: "WordPress username" },
                password: { type: "string", description: "WordPress password (not recommended)" },
                applicationPassword: { type: "string", description: "Application password (recommended)" },
                jwtToken: { type: "string", description: "JWT authentication token" }
              },
              required: ["siteUrl", "username"],
            },
          },
          {
            name: "wordpress_get_posts",
            description: "Retrieve WordPress posts",
            inputSchema: {
              type: "object",
              properties: {
                per_page: { type: "number", default: 10, maximum: 100 },
                page: { type: "number", default: 1 },
                search: { type: "string", description: "Search term" },
                status: { type: "string", enum: ["publish", "private", "draft"], default: "publish" },
                categories: { type: "array", items: { type: "number" }, description: "Category IDs" },
                tags: { type: "array", items: { type: "number" }, description: "Tag IDs" },
                author: { type: "number", description: "Author ID" },
                orderby: { type: "string", enum: ["date", "title", "modified"], default: "date" },
                order: { type: "string", enum: ["asc", "desc"], default: "desc" }
              }
            },
          },
          {
            name: "wordpress_get_post",
            description: "Get a specific WordPress post by ID",
            inputSchema: {
              type: "object",
              properties: {
                id: { type: "number", description: "Post ID" }
              },
              required: ["id"],
            },
          },
          {
            name: "wordpress_create_post",
            description: "Create a new WordPress post",
            inputSchema: {
              type: "object",
              properties: {
                title: { type: "string", description: "Post title" },
                content: { type: "string", description: "Post content (HTML)" },
                excerpt: { type: "string", description: "Post excerpt" },
                status: { type: "string", enum: ["publish", "private", "draft"], default: "draft" },
                categories: { type: "array", items: { type: "number" }, description: "Category IDs" },
                tags: { type: "array", items: { type: "number" }, description: "Tag IDs" },
                featured_media: { type: "number", description: "Featured image ID" },
                meta: { type: "object", description: "Custom fields" }
              },
              required: ["title", "content"],
            },
          },
          {
            name: "wordpress_update_post",
            description: "Update an existing WordPress post",
            inputSchema: {
              type: "object",
              properties: {
                id: { type: "number", description: "Post ID" },
                title: { type: "string", description: "Post title" },
                content: { type: "string", description: "Post content (HTML)" },
                excerpt: { type: "string", description: "Post excerpt" },
                status: { type: "string", enum: ["publish", "private", "draft"] },
                categories: { type: "array", items: { type: "number" }, description: "Category IDs" },
                tags: { type: "array", items: { type: "number" }, description: "Tag IDs" },
                featured_media: { type: "number", description: "Featured image ID" },
                meta: { type: "object", description: "Custom fields" }
              },
              required: ["id"],
            },
          },
          {
            name: "wordpress_delete_post",
            description: "Delete a WordPress post",
            inputSchema: {
              type: "object",
              properties: {
                id: { type: "number", description: "Post ID" },
                force: { type: "boolean", default: false, description: "Permanently delete (bypass trash)" }
              },
              required: ["id"],
            },
          },
          {
            name: "wordpress_get_pages",
            description: "Retrieve WordPress pages",
            inputSchema: {
              type: "object",
              properties: {
                per_page: { type: "number", default: 10, maximum: 100 },
                page: { type: "number", default: 1 },
                search: { type: "string", description: "Search term" },
                status: { type: "string", enum: ["publish", "private", "draft"], default: "publish" },
                parent: { type: "number", description: "Parent page ID" }
              }
            },
          },
          {
            name: "wordpress_create_page",
            description: "Create a new WordPress page",
            inputSchema: {
              type: "object",
              properties: {
                title: { type: "string", description: "Page title" },
                content: { type: "string", description: "Page content (HTML)" },
                parent: { type: "number", description: "Parent page ID" },
                status: { type: "string", enum: ["publish", "private", "draft"], default: "draft" },
                template: { type: "string", description: "Page template" },
                meta: { type: "object", description: "Custom fields" }
              },
              required: ["title", "content"],
            },
          },
          {
            name: "wordpress_get_categories",
            description: "Retrieve WordPress categories",
            inputSchema: {
              type: "object",
              properties: {
                per_page: { type: "number", default: 100 },
                hide_empty: { type: "boolean", default: false }
              }
            },
          },
          {
            name: "wordpress_get_tags",
            description: "Retrieve WordPress tags",
            inputSchema: {
              type: "object",
              properties: {
                per_page: { type: "number", default: 100 },
                hide_empty: { type: "boolean", default: false }
              }
            },
          },
          {
            name: "wordpress_upload_media",
            description: "Upload media file to WordPress",
            inputSchema: {
              type: "object",
              properties: {
                filePath: { type: "string", description: "Local file path" },
                title: { type: "string", description: "Media title" },
                alt_text: { type: "string", description: "Alt text for images" },
                caption: { type: "string", description: "Media caption" },
                description: { type: "string", description: "Media description" }
              },
              required: ["filePath"],
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
          case "wordpress_configure":
            return await this.configure(args);
          case "wordpress_get_posts":
            return await this.getPostsResponse(args);
          case "wordpress_get_post":
            return await this.getPostResponse(args);
          case "wordpress_create_post":
            return await this.createPostResponse(args);
          case "wordpress_update_post":
            return await this.updatePostResponse(args);
          case "wordpress_delete_post":
            return await this.deletePostResponse(args);
          case "wordpress_get_pages":
            return await this.getPagesResponse(args);
          case "wordpress_create_page":
            return await this.createPageResponse(args);
          case "wordpress_get_categories":
            return await this.getCategoriesResponse(args);
          case "wordpress_get_tags":
            return await this.getTagsResponse(args);
          case "wordpress_upload_media":
            return await this.uploadMediaResponse(args);
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
      this.config = WordPressConfigSchema.parse(args);
      
      const apiUrl = `${this.config.siteUrl.replace(/\/$/, '')}/wp-json/wp/v2`;
      
      this.apiClient = axios.create({
        baseURL: apiUrl,
        timeout: this.config.timeout,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      });

      // Set up authentication
      if (this.config.jwtToken) {
        this.apiClient.defaults.headers.common["Authorization"] = `Bearer ${this.config.jwtToken}`;
      } else if (this.config.applicationPassword) {
        this.apiClient.defaults.auth = {
          username: this.config.username,
          password: this.config.applicationPassword,
        };
      } else if (this.config.password) {
        this.apiClient.defaults.auth = {
          username: this.config.username,
          password: this.config.password,
        };
      }

      // Test connection
      await this.loadSiteInfo();

      return {
        content: [
          {
            type: "text",
            text: `Successfully configured WordPress connection to ${this.config.siteUrl}\nSite: ${this.siteInfo?.name || 'Unknown'}`
          }
        ]
      };
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : "Configuration failed";
      return {
        content: [
          {
            type: "text",
            text: `Failed to configure WordPress: ${errorMessage}`
          }
        ]
      };
    }
  }

  private async loadSiteInfo() {
    if (!this.apiClient) {
      throw new Error("WordPress API not configured");
    }

    try {
      const response = await this.apiClient.get("/");
      this.siteInfo = response.data;
    } catch (error) {
      throw new Error("Failed to load site information");
    }
  }

  private async getPosts(params: any = {}) {
    if (!this.apiClient) {
      throw new Error("WordPress API not configured");
    }

    const response = await this.apiClient.get("/posts", { params });
    return response.data;
  }

  private async getPostsResponse(args: any) {
    const posts = await this.getPosts(args);
    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(posts, null, 2)
        }
      ]
    };
  }

  private async getPostResponse(args: any) {
    if (!this.apiClient) {
      throw new Error("WordPress API not configured");
    }

    const { id } = args;
    const response = await this.apiClient.get(`/posts/${id}`);
    
    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(response.data, null, 2)
        }
      ]
    };
  }

  private async createPostResponse(args: any) {
    if (!this.apiClient) {
      throw new Error("WordPress API not configured");
    }

    const response = await this.apiClient.post("/posts", args);
    
    return {
      content: [
        {
          type: "text",
          text: `Post created successfully! ID: ${response.data.id}\n${JSON.stringify(response.data, null, 2)}`
        }
      ]
    };
  }

  private async updatePostResponse(args: any) {
    if (!this.apiClient) {
      throw new Error("WordPress API not configured");
    }

    const { id, ...updateData } = args;
    const response = await this.apiClient.put(`/posts/${id}`, updateData);
    
    return {
      content: [
        {
          type: "text",
          text: `Post updated successfully!\n${JSON.stringify(response.data, null, 2)}`
        }
      ]
    };
  }

  private async deletePostResponse(args: any) {
    if (!this.apiClient) {
      throw new Error("WordPress API not configured");
    }

    const { id, force = false } = args;
    const response = await this.apiClient.delete(`/posts/${id}`, {
      params: { force }
    });
    
    return {
      content: [
        {
          type: "text",
          text: `Post deleted successfully!\n${JSON.stringify(response.data, null, 2)}`
        }
      ]
    };
  }

  private async getPages(params: any = {}) {
    if (!this.apiClient) {
      throw new Error("WordPress API not configured");
    }

    const response = await this.apiClient.get("/pages", { params });
    return response.data;
  }

  private async getPagesResponse(args: any) {
    const pages = await this.getPages(args);
    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(pages, null, 2)
        }
      ]
    };
  }

  private async createPageResponse(args: any) {
    if (!this.apiClient) {
      throw new Error("WordPress API not configured");
    }

    const response = await this.apiClient.post("/pages", args);
    
    return {
      content: [
        {
          type: "text",
          text: `Page created successfully! ID: ${response.data.id}\n${JSON.stringify(response.data, null, 2)}`
        }
      ]
    };
  }

  private async getCategoriesResponse(args: any) {
    if (!this.apiClient) {
      throw new Error("WordPress API not configured");
    }

    const response = await this.apiClient.get("/categories", { params: args });
    
    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(response.data, null, 2)
        }
      ]
    };
  }

  private async getTagsResponse(args: any) {
    if (!this.apiClient) {
      throw new Error("WordPress API not configured");
    }

    const response = await this.apiClient.get("/tags", { params: args });
    
    return {
      content: [
        {
          type: "text",
          text: JSON.stringify(response.data, null, 2)
        }
      ]
    };
  }

  private async getMedia(params: any = {}) {
    if (!this.apiClient) {
      throw new Error("WordPress API not configured");
    }

    const response = await this.apiClient.get("/media", { params });
    return response.data;
  }

  private async uploadMediaResponse(args: any) {
    if (!this.apiClient) {
      throw new Error("WordPress API not configured");
    }

    // This would require file system access - placeholder implementation
    return {
      content: [
        {
          type: "text",
          text: "Media upload functionality requires file system access. Please implement file reading capability."
        }
      ]
    };
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error("WordPress REST API MCP server running on stdio");
  }
}

const server = new WordPressMCPServer();
server.run().catch(console.error);