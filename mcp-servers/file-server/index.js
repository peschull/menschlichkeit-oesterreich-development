#!/usr/bin/env node

/**
 * MCP File Server für Menschlichkeit Österreich
 * Bietet Dateizugriff für alle Services im Multi-Service Setup
 */

const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  Tool,
} = require('@modelcontextprotocol/sdk/types.js');
const fs = require('fs').promises;
const path = require('path');

class FileServerMCP {
  constructor() {
    this.server = new Server(
      {
        name: 'menschlichkeit-file-server',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.projectRoot = process.env.PROJECT_ROOT || process.cwd();
    this.setupHandlers();
  }

  setupHandlers() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: 'read_multi_service_file',
            description: 'Read files from any service directory (API, CRM, Frontend, Games, n8n)',
            inputSchema: {
              type: 'object',
              properties: {
                service: {
                  type: 'string',
                  enum: ['api', 'crm', 'frontend', 'games', 'website', 'n8n', 'root'],
                  description: 'Service directory to read from',
                },
                filePath: {
                  type: 'string',
                  description: 'Relative path within the service directory',
                },
              },
              required: ['service', 'filePath'],
            },
          },
          {
            name: 'list_service_files',
            description: 'List files and directories in a service',
            inputSchema: {
              type: 'object',
              properties: {
                service: {
                  type: 'string',
                  enum: ['api', 'crm', 'frontend', 'games', 'website', 'n8n', 'root'],
                },
                directory: {
                  type: 'string',
                  description: 'Directory path within service (optional)',
                  default: '.',
                },
              },
              required: ['service'],
            },
          },
          {
            name: 'get_project_structure',
            description: 'Get overview of multi-service project structure',
            inputSchema: {
              type: 'object',
              properties: {},
            },
          },
          {
            name: 'search_across_services',
            description: 'Search for text across all services',
            inputSchema: {
              type: 'object',
              properties: {
                query: {
                  type: 'string',
                  description: 'Text to search for',
                },
                fileTypes: {
                  type: 'array',
                  items: { type: 'string' },
                  description: 'File extensions to include (e.g., [".js", ".php", ".py"])',
                },
              },
              required: ['query'],
            },
          },
        ],
      };
    });

    this.server.setRequestHandler(CallToolRequestSchema, async request => {
      switch (request.params.name) {
        case 'read_multi_service_file':
          return await this.readMultiServiceFile(request.params.arguments);
        case 'list_service_files':
          return await this.listServiceFiles(request.params.arguments);
        case 'get_project_structure':
          return await this.getProjectStructure();
        case 'search_across_services':
          return await this.searchAcrossServices(request.params.arguments);
        default:
          throw new Error(`Unknown tool: ${request.params.name}`);
      }
    });
  }

  getServicePath(service) {
    const serviceMap = {
      api: 'api.menschlichkeit-oesterreich.at',
      crm: 'crm.menschlichkeit-oesterreich.at',
      frontend: 'frontend',
      games: 'web',
      website: 'website',
      n8n: 'automation/n8n',
      root: '.',
    };

    return path.join(this.projectRoot, serviceMap[service] || service);
  }

  async readMultiServiceFile({ service, filePath }) {
    try {
      const servicePath = this.getServicePath(service);
      const fullPath = path.join(servicePath, filePath);
      const content = await fs.readFile(fullPath, 'utf8');

      return {
        content: [
          {
            type: 'text',
            text: `File: ${service}/${filePath}\n\n${content}`,
          },
        ],
      };
    } catch (error) {
      return {
        content: [
          {
            type: 'text',
            text: `Error reading file: ${error.message}`,
          },
        ],
        isError: true,
      };
    }
  }

  async listServiceFiles({ service, directory = '.' }) {
    try {
      const servicePath = this.getServicePath(service);
      const fullPath = path.join(servicePath, directory);
      const items = await fs.readdir(fullPath, { withFileTypes: true });

      const fileList = items.map(item => ({
        name: item.name,
        type: item.isDirectory() ? 'directory' : 'file',
        path: path.join(directory, item.name),
      }));

      return {
        content: [
          {
            type: 'text',
            text: `Files in ${service}/${directory}:\n\n${JSON.stringify(fileList, null, 2)}`,
          },
        ],
      };
    } catch (error) {
      return {
        content: [
          {
            type: 'text',
            text: `Error listing files: ${error.message}`,
          },
        ],
        isError: true,
      };
    }
  }

  async getProjectStructure() {
    const structure = {
      services: [
        {
          name: 'API Service',
          path: 'api.menschlichkeit-oesterreich.at/',
          technology: 'FastAPI/Python',
          purpose: 'Backend API für Frontend und CRM Integration',
        },
        {
          name: 'CRM System',
          path: 'crm.menschlichkeit-oesterreich.at/',
          technology: 'Drupal 10 + CiviCRM',
          purpose: 'Mitgliederverwaltung und Spendenverwaltung',
        },
        {
          name: 'Frontend',
          path: 'frontend/',
          technology: 'React/TypeScript + TailwindCSS',
          purpose: 'Hauptwebsite mit Design System Integration',
        },
        {
          name: 'Gaming Platform',
          path: 'web/',
          technology: 'Web Games + Prisma/PostgreSQL',
          purpose: 'Educational democracy games',
        },
        {
          name: 'Website',
          path: 'website/',
          technology: 'WordPress/HTML',
          purpose: 'Statische Website-Inhalte',
        },
        {
          name: 'Automation',
          path: 'automation/n8n/',
          technology: 'n8n Workflows',
          purpose: 'Automatisierte Workflows und Integrationen',
        },
      ],
      keyFiles: [
        'schema.prisma - Database schema für Gaming Platform',
        'package.json - Monorepo workspace configuration',
        'composer.json - PHP dependencies für CRM/API',
        'build-pipeline.sh - Multi-service build automation',
        'scripts/plesk-sync.sh - Deployment synchronization',
        'figma-design-system/ - Design tokens und Branding',
      ],
    };

    return {
      content: [
        {
          type: 'text',
          text: `Multi-Service Project Structure:\n\n${JSON.stringify(structure, null, 2)}`,
        },
      ],
    };
  }

  async searchAcrossServices({ query, fileTypes = ['.js', '.php', '.py', '.ts', '.jsx', '.tsx'] }) {
    // Implementation for cross-service search would go here
    return {
      content: [
        {
          type: 'text',
          text: `Search functionality for "${query}" across services - Implementation pending`,
        },
      ],
    };
  }

  async start() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
  }
}

// Start server if run directly
if (require.main === module) {
  const server = new FileServerMCP();
  server.start().catch(console.error);
}

module.exports = FileServerMCP;
