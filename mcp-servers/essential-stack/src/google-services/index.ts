#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
    CallToolRequest,
    CallToolRequestSchema,
    ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import { config } from 'dotenv';
import { google } from 'googleapis';
import { z } from 'zod';

// Load environment variables
config();

const CREDENTIALS_PATH = process.env.GOOGLE_CREDENTIALS_PATH || '';
const SHEETS_ID = process.env.GOOGLE_SHEETS_ID || '';
const GMAIL_ADDRESS = process.env.GMAIL_ADDRESS || 'info@menschlichkeit-oesterreich.at';

const server = new Server(
  {
    name: 'menschlichkeit-google-services-mcp',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Initialize Google Auth
async function getGoogleAuth() {
  const auth = new google.auth.GoogleAuth({
    keyFile: CREDENTIALS_PATH,
    scopes: [
      'https://www.googleapis.com/auth/spreadsheets',
      'https://www.googleapis.com/auth/gmail.send',
      'https://www.googleapis.com/auth/gmail.readonly',
      'https://www.googleapis.com/auth/gmail.compose',
    ],
  });
  return await auth.getClient();
}

// Validation schemas
const AddMemberToSheetSchema = z.object({
  email: z.string().email(),
  first_name: z.string(),
  last_name: z.string(),
  membership_tier: z.enum(['basis', 'foerderer', 'unterstuetzer']),
  phone: z.string().optional(),
  registration_date: z.string().optional(),
  payment_status: z.enum(['pending', 'active', 'overdue', 'cancelled']).default('pending'),
  notes: z.string().optional(),
});

const UpdateMemberInSheetSchema = z.object({
  row_number: z.number(),
  email: z.string().email().optional(),
  first_name: z.string().optional(),
  last_name: z.string().optional(),
  membership_tier: z.enum(['basis', 'foerderer', 'unterstuetzer']).optional(),
  phone: z.string().optional(),
  payment_status: z.enum(['pending', 'active', 'overdue', 'cancelled']).optional(),
  notes: z.string().optional(),
});

const SendEmailSchema = z.object({
  to: z.string().email(),
  subject: z.string(),
  body: z.string(),
  is_html: z.boolean().default(true),
  cc: z.string().email().optional(),
  bcc: z.string().email().optional(),
});

const SearchMembersSchema = z.object({
  search_term: z.string(),
  column: z.enum(['email', 'first_name', 'last_name', 'membership_tier']).optional(),
});

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: 'google_sheets_add_member',
        description: 'Add new member to Google Sheets member database',
        inputSchema: {
          type: 'object',
          properties: {
            email: { type: 'string', description: 'Member email address' },
            first_name: { type: 'string', description: 'Member first name' },
            last_name: { type: 'string', description: 'Member last name' },
            membership_tier: { 
              type: 'string', 
              enum: ['basis', 'foerderer', 'unterstuetzer'],
              description: 'Membership tier'
            },
            phone: { type: 'string', description: 'Member phone number' },
            registration_date: { type: 'string', description: 'Registration date (YYYY-MM-DD)' },
            payment_status: { 
              type: 'string', 
              enum: ['pending', 'active', 'overdue', 'cancelled'],
              default: 'pending',
              description: 'Payment status'
            },
            notes: { type: 'string', description: 'Additional notes' },
          },
          required: ['email', 'first_name', 'last_name', 'membership_tier'],
        },
      },
      {
        name: 'google_sheets_update_member',
        description: 'Update existing member information in Google Sheets',
        inputSchema: {
          type: 'object',
          properties: {
            row_number: { type: 'number', description: 'Row number to update (starting from 1)' },
            email: { type: 'string', description: 'Member email address' },
            first_name: { type: 'string', description: 'Member first name' },
            last_name: { type: 'string', description: 'Member last name' },
            membership_tier: { 
              type: 'string', 
              enum: ['basis', 'foerderer', 'unterstuetzer'],
              description: 'Membership tier'
            },
            phone: { type: 'string', description: 'Member phone number' },
            payment_status: { 
              type: 'string', 
              enum: ['pending', 'active', 'overdue', 'cancelled'],
              description: 'Payment status'
            },
            notes: { type: 'string', description: 'Additional notes' },
          },
          required: ['row_number'],
        },
      },
      {
        name: 'google_sheets_search_members',
        description: 'Search for members in Google Sheets database',
        inputSchema: {
          type: 'object',
          properties: {
            search_term: { type: 'string', description: 'Term to search for' },
            column: { 
              type: 'string', 
              enum: ['email', 'first_name', 'last_name', 'membership_tier'],
              description: 'Specific column to search in (optional)'
            },
          },
          required: ['search_term'],
        },
      },
      {
        name: 'google_sheets_get_members',
        description: 'Get all members from Google Sheets with optional filtering',
        inputSchema: {
          type: 'object',
          properties: {
            membership_tier: { 
              type: 'string', 
              enum: ['basis', 'foerderer', 'unterstuetzer'],
              description: 'Filter by membership tier'
            },
            payment_status: { 
              type: 'string', 
              enum: ['pending', 'active', 'overdue', 'cancelled'],
              description: 'Filter by payment status'
            },
            limit: { type: 'number', default: 50, description: 'Maximum number of results' },
          },
          required: [],
        },
      },
      {
        name: 'gmail_send_email',
        description: 'Send email via Gmail on behalf of organization',
        inputSchema: {
          type: 'object',
          properties: {
            to: { type: 'string', description: 'Recipient email address' },
            subject: { type: 'string', description: 'Email subject' },
            body: { type: 'string', description: 'Email body content' },
            is_html: { type: 'boolean', default: true, description: 'Whether body is HTML format' },
            cc: { type: 'string', description: 'CC email address' },
            bcc: { type: 'string', description: 'BCC email address' },
          },
          required: ['to', 'subject', 'body'],
        },
      },
      {
        name: 'gmail_get_recent_emails',
        description: 'Get recent emails from organizational Gmail account',
        inputSchema: {
          type: 'object',
          properties: {
            max_results: { type: 'number', default: 10, description: 'Maximum number of emails to retrieve' },
            query: { type: 'string', description: 'Gmail search query (e.g., "from:member@email.com")' },
          },
          required: [],
        },
      },
      {
        name: 'google_sheets_get_stats',
        description: 'Get membership statistics from Google Sheets',
        inputSchema: {
          type: 'object',
          properties: {},
          required: [],
        },
      },
    ],
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request: CallToolRequest) => {
  const { name, arguments: args } = request.params;

  try {
    const authClient = await getGoogleAuth();
    const sheets = google.sheets({ version: 'v4', auth: authClient as any });
    const gmail = google.gmail({ version: 'v1', auth: authClient as any });

    switch (name) {
      case 'google_sheets_add_member': {
        const data = AddMemberToSheetSchema.parse(args);
        
        const values = [[
          data.email,
          data.first_name,
          data.last_name,
          data.membership_tier,
          data.phone || '',
          data.registration_date || new Date().toISOString().split('T')[0],
          data.payment_status,
          data.notes || '',
          new Date().toISOString() // Timestamp
        ]];

        const result = await sheets.spreadsheets.values.append({
          spreadsheetId: SHEETS_ID,
          range: 'Mitglieder!A:I',
          valueInputOption: 'RAW',
          requestBody: { values },
        });

        return {
          content: [
            {
              type: 'text',
              text: `Mitglied erfolgreich zu Google Sheets hinzugefügt:
Email: ${data.email}
Name: ${data.first_name} ${data.last_name}
Mitgliedschaftsstufe: ${data.membership_tier}
Status: ${data.payment_status}
Zeile: ${result.data.updates?.updatedRows} hinzugefügt`,
            },
          ],
        };
      }

      case 'google_sheets_update_member': {
        const data = UpdateMemberInSheetSchema.parse(args);
        
        // First get current row data
        const currentData = await sheets.spreadsheets.values.get({
          spreadsheetId: SHEETS_ID,
          range: `Mitglieder!A${data.row_number}:I${data.row_number}`,
        });

        const currentRow = currentData.data.values?.[0] || [];
        
        // Update only provided fields
        const updatedRow = [
          data.email || currentRow[0],
          data.first_name || currentRow[1],
          data.last_name || currentRow[2],
          data.membership_tier || currentRow[3],
          data.phone !== undefined ? data.phone : currentRow[4],
          currentRow[5], // Keep registration date
          data.payment_status || currentRow[6],
          data.notes !== undefined ? data.notes : currentRow[7],
          new Date().toISOString(), // Update timestamp
        ];

        await sheets.spreadsheets.values.update({
          spreadsheetId: SHEETS_ID,
          range: `Mitglieder!A${data.row_number}:I${data.row_number}`,
          valueInputOption: 'RAW',
          requestBody: { values: [updatedRow] },
        });

        return {
          content: [
            {
              type: 'text',
              text: `Mitglied erfolgreich aktualisiert (Zeile ${data.row_number}):
Email: ${updatedRow[0]}
Name: ${updatedRow[1]} ${updatedRow[2]}
Mitgliedschaftsstufe: ${updatedRow[3]}
Status: ${updatedRow[6]}`,
            },
          ],
        };
      }

      case 'google_sheets_search_members': {
        const { search_term, column } = SearchMembersSchema.parse(args);
        
        const response = await sheets.spreadsheets.values.get({
          spreadsheetId: SHEETS_ID,
          range: 'Mitglieder!A:I',
        });

        const rows = response.data.values || [];
        const headers = rows[0] || [];
        const dataRows = rows.slice(1);

        let matchingRows: any[] = [];

        if (column) {
          const columnIndex = ['email', 'first_name', 'last_name', 'membership_tier'].indexOf(column);
          if (columnIndex !== -1) {
            matchingRows = dataRows.filter((row, index) => 
              row[columnIndex]?.toLowerCase().includes(search_term.toLowerCase())
            ).map((row, originalIndex) => ({ row, index: originalIndex + 2 }));
          }
        } else {
          // Search all text columns
          matchingRows = dataRows.filter((row, index) => 
            row.some((cell: string) => 
              cell?.toLowerCase().includes(search_term.toLowerCase())
            )
          ).map((row, originalIndex) => ({ row, index: originalIndex + 2 }));
        }

        const results = matchingRows.slice(0, 20).map(({ row, index }) => {
          return `• Zeile ${index}: ${row[1]} ${row[2]} (${row[0]})
  Mitgliedschaft: ${row[3]}
  Status: ${row[6]}
  Telefon: ${row[4] || 'Nicht angegeben'}`;
        }).join('\n\n');

        return {
          content: [
            {
              type: 'text',
              text: `Suchergebnisse für "${search_term}" (${matchingRows.length} gefunden):

${results}`,
            },
          ],
        };
      }

      case 'google_sheets_get_members': {
        const membershipFilter = (args as any)?.membership_tier;
        const paymentFilter = (args as any)?.payment_status;
        const limit = (args as any)?.limit || 50;
        
        const response = await sheets.spreadsheets.values.get({
          spreadsheetId: SHEETS_ID,
          range: 'Mitglieder!A:I',
        });

        const rows = response.data.values || [];
        const headers = rows[0] || [];
        let dataRows = rows.slice(1);

        // Apply filters
        if (membershipFilter) {
          dataRows = dataRows.filter(row => row[3] === membershipFilter);
        }
        if (paymentFilter) {
          dataRows = dataRows.filter(row => row[6] === paymentFilter);
        }

        const limitedRows = dataRows.slice(0, limit);
        
        const membersList = limitedRows.map((row, index) => {
          return `• ${row[1]} ${row[2]} (${row[0]})
  Mitgliedschaft: ${row[3]}
  Status: ${row[6]}
  Registriert: ${row[5]}
  Telefon: ${row[4] || 'Nicht angegeben'}`;
        }).join('\n\n');

        return {
          content: [
            {
              type: 'text',
              text: `Mitglieder (${limitedRows.length}/${dataRows.length} angezeigt):

${membersList}`,
            },
          ],
        };
      }

      case 'gmail_send_email': {
        const data = SendEmailSchema.parse(args);
        
        const messageParts = [
          `To: ${data.to}`,
          `Subject: ${data.subject}`,
          `From: ${GMAIL_ADDRESS}`,
        ];

        if (data.cc) messageParts.push(`Cc: ${data.cc}`);
        if (data.bcc) messageParts.push(`Bcc: ${data.bcc}`);

        messageParts.push(`Content-Type: ${data.is_html ? 'text/html' : 'text/plain'}; charset=utf-8`);
        messageParts.push('');
        messageParts.push(data.body);

        const message = messageParts.join('\n');
        const encodedMessage = Buffer.from(message).toString('base64').replace(/\+/g, '-').replace(/\//g, '_');

        const result = await gmail.users.messages.send({
          userId: 'me',
          requestBody: {
            raw: encodedMessage,
          },
        });

        return {
          content: [
            {
              type: 'text',
              text: `Email erfolgreich versendet:
An: ${data.to}
Betreff: ${data.subject}
Message ID: ${result.data.id}
Von: ${GMAIL_ADDRESS}`,
            },
          ],
        };
      }

      case 'gmail_get_recent_emails': {
        const maxResults = (args as any)?.max_results || 10;
        const query = (args as any)?.query || '';
        
        const response = await gmail.users.messages.list({
          userId: 'me',
          maxResults,
          q: query,
        });

        const messages = response.data.messages || [];
        
        const emailDetails = await Promise.all(
          messages.slice(0, 5).map(async (message) => {
            const details = await gmail.users.messages.get({
              userId: 'me',
              id: message.id!,
              format: 'metadata',
              metadataHeaders: ['From', 'Subject', 'Date'],
            });

            const headers = details.data.payload?.headers || [];
            const from = headers.find(h => h.name === 'From')?.value || '';
            const subject = headers.find(h => h.name === 'Subject')?.value || '';
            const date = headers.find(h => h.name === 'Date')?.value || '';

            return `• ${subject}
  Von: ${from}
  Datum: ${new Date(date).toLocaleDateString('de-AT')}
  ID: ${message.id}`;
          })
        );

        return {
          content: [
            {
              type: 'text',
              text: `Letzte ${messages.length} E-Mails:

${emailDetails.join('\n\n')}`,
            },
          ],
        };
      }

      case 'google_sheets_get_stats': {
        const response = await sheets.spreadsheets.values.get({
          spreadsheetId: SHEETS_ID,
          range: 'Mitglieder!A:I',
        });

        const rows = response.data.values || [];
        const dataRows = rows.slice(1);

        const stats = {
          total: dataRows.length,
          basis: dataRows.filter(row => row[3] === 'basis').length,
          foerderer: dataRows.filter(row => row[3] === 'foerderer').length,
          unterstuetzer: dataRows.filter(row => row[3] === 'unterstuetzer').length,
          active: dataRows.filter(row => row[6] === 'active').length,
          pending: dataRows.filter(row => row[6] === 'pending').length,
          overdue: dataRows.filter(row => row[6] === 'overdue').length,
        };

        // Get recent registrations (last 30 days)
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
        const recentRegistrations = dataRows.filter(row => {
          const regDate = new Date(row[5]);
          return regDate >= thirtyDaysAgo;
        }).length;

        return {
          content: [
            {
              type: 'text',
              text: `📊 Mitgliedschaftsstatistiken - Google Sheets

👥 Mitgliederzahlen:
• Gesamt: ${stats.total}
• Basis: ${stats.basis}
• Förderer: ${stats.foerderer}
• Unterstützer: ${stats.unterstuetzer}

💳 Zahlungsstatus:
• Aktiv: ${stats.active}
• Ausstehend: ${stats.pending}
• Überfällig: ${stats.overdue}

📈 Wachstum:
• Neue Registrierungen (30 Tage): ${recentRegistrations}`,
            },
          ],
        };
      }

      default:
        throw new Error(`Unbekanntes Tool: ${name}`);
    }
  } catch (error) {
    return {
      content: [
        {
          type: 'text',
          text: `Fehler beim Ausführen von ${name}: ${error instanceof Error ? error.message : String(error)}`,
        },
      ],
      isError: true,
    };
  }
});

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('Menschlichkeit Österreich Google Services MCP Server gestartet');
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch(console.error);
}

export { server };
