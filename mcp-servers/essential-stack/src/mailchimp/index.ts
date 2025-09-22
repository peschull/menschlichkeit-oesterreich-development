#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
    CallToolRequest,
    CallToolRequestSchema,
    ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import { config } from 'dotenv';
import fetch from 'node-fetch';
import { z } from 'zod';

// Load environment variables
config();

const MAILCHIMP_API_KEY = process.env.MAILCHIMP_API_KEY || '';
const MAILCHIMP_SERVER_PREFIX = process.env.MAILCHIMP_SERVER_PREFIX || 'us1';
const MAILCHIMP_AUDIENCE_ID = process.env.MAILCHIMP_AUDIENCE_ID || '';
const BASE_URL = `https://${MAILCHIMP_SERVER_PREFIX}.api.mailchimp.com/3.0`;

const server = new Server(
  {
    name: 'menschlichkeit-mailchimp-mcp',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// API Helper function
async function mailchimpRequest(endpoint: string, method: string = 'GET', body?: any): Promise<any> {
  const url = `${BASE_URL}${endpoint}`;
  const auth = Buffer.from(`user:${MAILCHIMP_API_KEY}`).toString('base64');
  
  const response = await fetch(url, {
    method,
    headers: {
      'Authorization': `Basic ${auth}`,
      'Content-Type': 'application/json',
    },
    body: body ? JSON.stringify(body) : undefined,
  });

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Mailchimp API error: ${response.status} - ${error}`);
  }

  return await response.json();
}

// Validation schemas
const AddMemberSchema = z.object({
  email: z.string().email(),
  first_name: z.string().optional(),
  last_name: z.string().optional(),
  membership_tier: z.enum(['basis', 'foerderer', 'unterstuetzer']).optional(),
  merge_fields: z.record(z.any()).optional(),
  interests: z.record(z.boolean()).optional(),
  status: z.enum(['subscribed', 'unsubscribed', 'cleaned', 'pending']).default('subscribed'),
});

const UpdateMemberSchema = z.object({
  email: z.string().email(),
  first_name: z.string().optional(),
  last_name: z.string().optional(),
  membership_tier: z.enum(['basis', 'foerderer', 'unterstuetzer']).optional(),
  merge_fields: z.record(z.any()).optional(),
  interests: z.record(z.boolean()).optional(),
  status: z.enum(['subscribed', 'unsubscribed', 'cleaned', 'pending']).optional(),
});

const CreateCampaignSchema = z.object({
  subject: z.string(),
  title: z.string(),
  from_name: z.string().default('Menschlichkeit Österreich'),
  reply_to: z.string().email().default('info@menschlichkeit-oesterreich.at'),
  to_name: z.string().default('*|FNAME|* *|LNAME|*'),
  html_content: z.string(),
  text_content: z.string().optional(),
  segment_opts: z.object({
    match: z.enum(['any', 'all']).default('any'),
    conditions: z.array(z.any()).optional(),
  }).optional(),
});

const GetMemberSchema = z.object({
  email: z.string().email(),
});

const SearchMembersSchema = z.object({
  query: z.string(),
  fields: z.string().default('members.email_address,members.full_name,members.status'),
});

const SendCampaignSchema = z.object({
  campaign_id: z.string(),
});

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: 'mailchimp_add_member',
        description: 'Add new member to Menschlichkeit Österreich mailing list',
        inputSchema: {
          type: 'object',
          properties: {
            email: { type: 'string', description: 'Member email address' },
            first_name: { type: 'string', description: 'Member first name' },
            last_name: { type: 'string', description: 'Member last name' },
            membership_tier: { 
              type: 'string', 
              enum: ['basis', 'foerderer', 'unterstuetzer'],
              description: 'Membership tier for segmentation'
            },
            merge_fields: { type: 'object', description: 'Custom merge fields' },
            interests: { type: 'object', description: 'Interest group preferences' },
            status: { 
              type: 'string', 
              enum: ['subscribed', 'unsubscribed', 'cleaned', 'pending'],
              default: 'subscribed',
              description: 'Subscription status'
            },
          },
          required: ['email'],
        },
      },
      {
        name: 'mailchimp_update_member',
        description: 'Update existing member information and preferences',
        inputSchema: {
          type: 'object',
          properties: {
            email: { type: 'string', description: 'Member email address' },
            first_name: { type: 'string', description: 'Member first name' },
            last_name: { type: 'string', description: 'Member last name' },
            membership_tier: { 
              type: 'string', 
              enum: ['basis', 'foerderer', 'unterstuetzer'],
              description: 'Membership tier for segmentation'
            },
            merge_fields: { type: 'object', description: 'Custom merge fields' },
            interests: { type: 'object', description: 'Interest group preferences' },
            status: { 
              type: 'string', 
              enum: ['subscribed', 'unsubscribed', 'cleaned', 'pending'],
              description: 'Subscription status'
            },
          },
          required: ['email'],
        },
      },
      {
        name: 'mailchimp_get_member',
        description: 'Get member information by email address',
        inputSchema: {
          type: 'object',
          properties: {
            email: { type: 'string', description: 'Member email address' },
          },
          required: ['email'],
        },
      },
      {
        name: 'mailchimp_search_members',
        description: 'Search members by query string',
        inputSchema: {
          type: 'object',
          properties: {
            query: { type: 'string', description: 'Search query (name, email, etc.)' },
            fields: { 
              type: 'string', 
              default: 'members.email_address,members.full_name,members.status',
              description: 'Fields to return in search results'
            },
          },
          required: ['query'],
        },
      },
      {
        name: 'mailchimp_create_campaign',
        description: 'Create newsletter campaign for members',
        inputSchema: {
          type: 'object',
          properties: {
            subject: { type: 'string', description: 'Email subject line' },
            title: { type: 'string', description: 'Campaign title (internal)' },
            from_name: { type: 'string', default: 'Menschlichkeit Österreich', description: 'Sender name' },
            reply_to: { type: 'string', default: 'info@menschlichkeit-oesterreich.at', description: 'Reply-to email' },
            to_name: { type: 'string', default: '*|FNAME|* *|LNAME|*', description: 'Recipient merge tag' },
            html_content: { type: 'string', description: 'HTML email content' },
            text_content: { type: 'string', description: 'Plain text email content (optional)' },
            segment_opts: { 
              type: 'object', 
              description: 'Audience segmentation options',
              properties: {
                match: { type: 'string', enum: ['any', 'all'], default: 'any' },
                conditions: { type: 'array', description: 'Segmentation conditions' },
              }
            },
          },
          required: ['subject', 'title', 'html_content'],
        },
      },
      {
        name: 'mailchimp_send_campaign',
        description: 'Send campaign immediately to selected audience',
        inputSchema: {
          type: 'object',
          properties: {
            campaign_id: { type: 'string', description: 'Campaign ID to send' },
          },
          required: ['campaign_id'],
        },
      },
      {
        name: 'mailchimp_list_campaigns',
        description: 'List recent campaigns with status and stats',
        inputSchema: {
          type: 'object',
          properties: {
            count: { type: 'number', default: 10, description: 'Number of campaigns to return' },
            status: { 
              type: 'string', 
              enum: ['save', 'paused', 'schedule', 'sending', 'sent'],
              description: 'Filter by campaign status'
            },
          },
          required: [],
        },
      },
      {
        name: 'mailchimp_get_audience_stats',
        description: 'Get audience statistics and growth metrics',
        inputSchema: {
          type: 'object',
          properties: {},
          required: [],
        },
      },
      {
        name: 'mailchimp_unsubscribe_member',
        description: 'Unsubscribe member from mailing list',
        inputSchema: {
          type: 'object',
          properties: {
            email: { type: 'string', description: 'Member email address to unsubscribe' },
          },
          required: ['email'],
        },
      },
    ],
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request: CallToolRequest) => {
  const { name, arguments: args } = request.params;

  try {
    switch (name) {
      case 'mailchimp_add_member': {
        const data = AddMemberSchema.parse(args);
        
        // Create MD5 hash of email for subscriber ID
        const crypto = await import('crypto');
        const subscriberHash = crypto.createHash('md5').update(data.email.toLowerCase()).digest('hex');
        
        const memberData = {
          email_address: data.email,
          status: data.status,
          merge_fields: {
            FNAME: data.first_name || '',
            LNAME: data.last_name || '',
            MTYPE: data.membership_tier || 'basis',
            ORGANIZ: 'Menschlichkeit Österreich',
            ...data.merge_fields,
          },
          interests: data.interests || {},
        };

        const result: any = await mailchimpRequest(`/lists/${MAILCHIMP_AUDIENCE_ID}/members/${subscriberHash}`, 'PUT', memberData);

        return {
          content: [
            {
              type: 'text',
              text: `Mitglied erfolgreich hinzugefügt:
Email: ${result.email_address}
Name: ${result.full_name}
Status: ${result.status}
Mitgliedschaftsstufe: ${result.merge_fields?.MTYPE || 'basis'}
Hinzugefügt: ${new Date(result.timestamp_opt).toLocaleDateString('de-AT')}`,
            },
          ],
        };
      }

      case 'mailchimp_update_member': {
        const data = UpdateMemberSchema.parse(args);
        
        const crypto = await import('crypto');
        const subscriberHash = crypto.createHash('md5').update(data.email.toLowerCase()).digest('hex');
        
        const updateData: any = {};
        if (data.first_name !== undefined) updateData.merge_fields = { ...updateData.merge_fields, FNAME: data.first_name };
        if (data.last_name !== undefined) updateData.merge_fields = { ...updateData.merge_fields, LNAME: data.last_name };
        if (data.membership_tier !== undefined) updateData.merge_fields = { ...updateData.merge_fields, MTYPE: data.membership_tier };
        if (data.status !== undefined) updateData.status = data.status;
        if (data.interests !== undefined) updateData.interests = data.interests;
        if (data.merge_fields !== undefined) updateData.merge_fields = { ...updateData.merge_fields, ...data.merge_fields };

        const result: any = await mailchimpRequest(`/lists/${MAILCHIMP_AUDIENCE_ID}/members/${subscriberHash}`, 'PATCH', updateData);

        return {
          content: [
            {
              type: 'text',
              text: `Mitglied erfolgreich aktualisiert:
Email: ${result.email_address}
Name: ${result.full_name}
Status: ${result.status}
Mitgliedschaftsstufe: ${result.merge_fields?.MTYPE || 'basis'}
Letzte Aktualisierung: ${new Date(result.last_changed).toLocaleDateString('de-AT')}`,
            },
          ],
        };
      }

      case 'mailchimp_get_member': {
        const { email } = GetMemberSchema.parse(args);
        
        const crypto = await import('crypto');
        const subscriberHash = crypto.createHash('md5').update(email.toLowerCase()).digest('hex');
        
        const member: any = await mailchimpRequest(`/lists/${MAILCHIMP_AUDIENCE_ID}/members/${subscriberHash}`);

        return {
          content: [
            {
              type: 'text',
              text: `Mitgliedsinformationen:
Email: ${member.email_address}
Name: ${member.full_name}
Status: ${member.status}
Mitgliedschaftsstufe: ${member.merge_fields?.MTYPE || 'basis'}
Angemeldet seit: ${new Date(member.timestamp_opt).toLocaleDateString('de-AT')}
Letzte Aktualisierung: ${new Date(member.last_changed).toLocaleDateString('de-AT')}
Email-Client: ${member.last_note?.note || 'Unbekannt'}`,
            },
          ],
        };
      }

      case 'mailchimp_search_members': {
        const { query, fields } = SearchMembersSchema.parse(args);
        
        const searchResults: any = await mailchimpRequest(`/search-members?query=${encodeURIComponent(query)}&fields=${fields}`);

        const membersList = searchResults.full_search.members.map((member: any) => {
          return `• ${member.full_name || member.email_address}
  Email: ${member.email_address}
  Status: ${member.status}
  Liste: ${member.list.name}`;
        }).join('\n\n');

        return {
          content: [
            {
              type: 'text',
              text: `Suchergebnisse für "${query}" (${searchResults.full_search.members.length} gefunden):

${membersList}`,
            },
          ],
        };
      }

      case 'mailchimp_create_campaign': {
        const data = CreateCampaignSchema.parse(args);
        
        const campaignData = {
          type: 'regular',
          recipients: {
            list_id: MAILCHIMP_AUDIENCE_ID,
            segment_opts: data.segment_opts,
          },
          settings: {
            subject_line: data.subject,
            title: data.title,
            from_name: data.from_name,
            reply_to: data.reply_to,
            to_name: data.to_name,
            authenticate: true,
            auto_footer: false,
            inline_css: true,
          },
        };

        const campaign: any = await mailchimpRequest('/campaigns', 'POST', campaignData);

        // Set campaign content
        const contentData = {
          html: data.html_content,
          plain_text: data.text_content,
        };

        await mailchimpRequest(`/campaigns/${campaign.id}/content`, 'PUT', contentData);

        return {
          content: [
            {
              type: 'text',
              text: `Newsletter-Kampagne erstellt:
ID: ${campaign.id}
Titel: ${campaign.settings.title}
Betreff: ${campaign.settings.subject_line}
Status: ${campaign.status}
Zielgruppe: ${campaign.recipients.list_name}
Erstellt: ${new Date(campaign.create_time).toLocaleDateString('de-AT')}`,
            },
          ],
        };
      }

      case 'mailchimp_send_campaign': {
        const { campaign_id } = SendCampaignSchema.parse(args);
        
        await mailchimpRequest(`/campaigns/${campaign_id}/actions/send`, 'POST');
        const campaign: any = await mailchimpRequest(`/campaigns/${campaign_id}`);

        return {
          content: [
            {
              type: 'text',
              text: `Kampagne erfolgreich versendet:
ID: ${campaign.id}
Titel: ${campaign.settings.title}
Status: ${campaign.status}
Empfänger: ${campaign.recipients.recipient_count}
Versendet: ${new Date(campaign.send_time).toLocaleDateString('de-AT')}`,
            },
          ],
        };
      }

      case 'mailchimp_list_campaigns': {
        const count = (args as any)?.count || 10;
        const status = (args as any)?.status;
        
        let endpoint = `/campaigns?count=${count}`;
        if (status) endpoint += `&status=${status}`;
        
        const campaigns: any = await mailchimpRequest(endpoint);

        const campaignList = campaigns.campaigns.map((campaign: any) => {
          const stats = campaign.report_summary || {};
          return `• ${campaign.settings.title} (${campaign.id})
  Betreff: ${campaign.settings.subject_line}
  Status: ${campaign.status}
  Empfänger: ${stats.recipient_count || 0}
  Öffnungsrate: ${stats.open_rate ? (stats.open_rate * 100).toFixed(1) + '%' : 'N/A'}
  Erstellt: ${new Date(campaign.create_time).toLocaleDateString('de-AT')}`;
        }).join('\n\n');

        return {
          content: [
            {
              type: 'text',
              text: `Kampagnen (${campaigns.campaigns.length}):

${campaignList}`,
            },
          ],
        };
      }

      case 'mailchimp_get_audience_stats': {
        const audience: any = await mailchimpRequest(`/lists/${MAILCHIMP_AUDIENCE_ID}`);
        const growth: any = await mailchimpRequest(`/lists/${MAILCHIMP_AUDIENCE_ID}/growth-history?count=12`);
        
        const recentGrowth = growth.history.slice(0, 3).map((month: any) => {
          return `  ${month.month}: +${month.subscribed} / -${month.unsubscribed}`;
        }).join('\n');

        return {
          content: [
            {
              type: 'text',
              text: `📊 Mailing List Statistiken - ${audience.name}

👥 Mitgliederstand:
• Gesamte Mitglieder: ${audience.stats.member_count}
• Angemeldet: ${audience.stats.member_count_since_send}
• Abgemeldet: ${audience.stats.unsubscribe_count}
• Bereinigt: ${audience.stats.cleaned_count}

📈 Wachstum (letzte 3 Monate):
${recentGrowth}

📊 Durchschnittliche Statistiken:
• Öffnungsrate: ${(audience.stats.open_rate * 100).toFixed(1)}%
• Klickrate: ${(audience.stats.click_rate * 100).toFixed(1)}%
• Abmelderate: ${(audience.stats.unsubscribe_count_since_send / audience.stats.member_count * 100).toFixed(1)}%

📅 Liste erstellt: ${new Date(audience.date_created).toLocaleDateString('de-AT')}`,
            },
          ],
        };
      }

      case 'mailchimp_unsubscribe_member': {
        const { email } = GetMemberSchema.parse(args);
        
        const crypto = await import('crypto');
        const subscriberHash = crypto.createHash('md5').update(email.toLowerCase()).digest('hex');
        
        const result: any = await mailchimpRequest(`/lists/${MAILCHIMP_AUDIENCE_ID}/members/${subscriberHash}`, 'PATCH', {
          status: 'unsubscribed'
        });

        return {
          content: [
            {
              type: 'text',
              text: `Mitglied erfolgreich abgemeldet:
Email: ${result.email_address}
Name: ${result.full_name}
Status: ${result.status}
Abgemeldet: ${new Date().toLocaleDateString('de-AT')}`,
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
  console.error('Menschlichkeit Österreich Mailchimp MCP Server gestartet');
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch(console.error);
}

export { server };
