#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
    CallToolRequest,
    CallToolRequestSchema,
    ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import { config } from 'dotenv';
import Stripe from 'stripe';
import { z } from 'zod';

// Load environment variables
config();

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY || process.env.STRIPE_TEST_SECRET_KEY || '', {
  apiVersion: '2025-08-27.basil',
});

// Membership tiers for Menschlichkeit Österreich
const MEMBERSHIP_TIERS = {
  basis: { price: 0, name: 'Basis Mitgliedschaft', features: ['Newsletter', 'Community Zugang'] },
  foerderer: { price: 1800, name: 'Förderer', features: ['Alle Basis Features', 'Exklusive Updates', 'Direkte Kommunikation'] }, // €18.00 in cents
  unterstuetzer: { price: 3600, name: 'Unterstützer', features: ['Alle Features', 'Persönliche Beratung', 'VIP Events', 'Jahresbericht'] } // €36.00 in cents
} as const;

type MembershipTier = keyof typeof MEMBERSHIP_TIERS;

const server = new Server(
  {
    name: 'menschlichkeit-stripe-mcp',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Validation schemas
const CreateCustomerSchema = z.object({
  email: z.string().email(),
  name: z.string(),
  phone: z.string().optional(),
  membership_tier: z.enum(['basis', 'foerderer', 'unterstuetzer']),
});

const CreatePaymentIntentSchema = z.object({
  customer_id: z.string(),
  membership_tier: z.enum(['basis', 'foerderer', 'unterstuetzer']),
  currency: z.string().default('eur'),
});

const CreateSubscriptionSchema = z.object({
  customer_id: z.string(),
  membership_tier: z.enum(['basis', 'foerderer', 'unterstuetzer']),
  payment_method_id: z.string(),
});

const GetCustomerSchema = z.object({
  customer_id: z.string(),
});

const ListCustomersSchema = z.object({
  limit: z.number().optional().default(10),
  starting_after: z.string().optional(),
});

const CancelSubscriptionSchema = z.object({
  subscription_id: z.string(),
});

server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: 'stripe_create_customer',
        description: 'Create a new Stripe customer for Menschlichkeit Österreich membership',
        inputSchema: {
          type: 'object',
          properties: {
            email: { type: 'string', description: 'Customer email address' },
            name: { type: 'string', description: 'Customer full name' },
            phone: { type: 'string', description: 'Customer phone number (optional)' },
            membership_tier: { 
              type: 'string', 
              enum: ['basis', 'foerderer', 'unterstuetzer'],
              description: 'Membership tier: basis (€0), foerderer (€18), unterstuetzer (€36)'
            },
          },
          required: ['email', 'name', 'membership_tier'],
        },
      },
      {
        name: 'stripe_create_payment_intent',
        description: 'Create a payment intent for membership fees',
        inputSchema: {
          type: 'object',
          properties: {
            customer_id: { type: 'string', description: 'Stripe customer ID' },
            membership_tier: { 
              type: 'string', 
              enum: ['basis', 'foerderer', 'unterstuetzer'],
              description: 'Membership tier to charge for'
            },
            currency: { type: 'string', description: 'Currency code', default: 'eur' },
          },
          required: ['customer_id', 'membership_tier'],
        },
      },
      {
        name: 'stripe_create_subscription',
        description: 'Create annual membership subscription',
        inputSchema: {
          type: 'object',
          properties: {
            customer_id: { type: 'string', description: 'Stripe customer ID' },
            membership_tier: { 
              type: 'string', 
              enum: ['basis', 'foerderer', 'unterstuetzer'],
              description: 'Membership tier for subscription'
            },
            payment_method_id: { type: 'string', description: 'Payment method ID' },
          },
          required: ['customer_id', 'membership_tier', 'payment_method_id'],
        },
      },
      {
        name: 'stripe_get_customer',
        description: 'Retrieve customer information by ID',
        inputSchema: {
          type: 'object',
          properties: {
            customer_id: { type: 'string', description: 'Stripe customer ID' },
          },
          required: ['customer_id'],
        },
      },
      {
        name: 'stripe_list_customers',
        description: 'List all customers with pagination',
        inputSchema: {
          type: 'object',
          properties: {
            limit: { type: 'number', description: 'Number of customers to return (max 100)', default: 10 },
            starting_after: { type: 'string', description: 'Customer ID to start after for pagination' },
          },
          required: [],
        },
      },
      {
        name: 'stripe_cancel_subscription',
        description: 'Cancel an active subscription',
        inputSchema: {
          type: 'object',
          properties: {
            subscription_id: { type: 'string', description: 'Subscription ID to cancel' },
          },
          required: ['subscription_id'],
        },
      },
      {
        name: 'stripe_list_payments',
        description: 'List recent payments and transactions',
        inputSchema: {
          type: 'object',
          properties: {
            limit: { type: 'number', description: 'Number of payments to return', default: 10 },
          },
          required: [],
        },
      },
      {
        name: 'stripe_get_membership_stats',
        description: 'Get membership statistics and revenue overview',
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
    switch (name) {
      case 'stripe_create_customer': {
        const { email, name: customerName, phone, membership_tier } = CreateCustomerSchema.parse(args);
        
        const customer = await stripe.customers.create({
          email,
          name: customerName,
          phone,
          metadata: {
            membership_tier,
            organization: 'Menschlichkeit Österreich',
            zvr_number: '1182213083',
          },
        });

        return {
          content: [
            {
              type: 'text',
              text: `Kunde erfolgreich erstellt:
ID: ${customer.id}
Email: ${customer.email}
Name: ${customer.name}
Mitgliedschaftsstufe: ${MEMBERSHIP_TIERS[membership_tier as MembershipTier].name}
Jahresbeitrag: €${MEMBERSHIP_TIERS[membership_tier as MembershipTier].price / 100}`,
            },
          ],
        };
      }

      case 'stripe_create_payment_intent': {
        const { customer_id, membership_tier, currency } = CreatePaymentIntentSchema.parse(args);
        const tier = MEMBERSHIP_TIERS[membership_tier as MembershipTier];
        
        if (tier.price === 0) {
          return {
            content: [
              {
                type: 'text',
                text: `Basis Mitgliedschaft ist kostenlos - keine Zahlung erforderlich für Kunde ${customer_id}`,
              },
            ],
          };
        }

        const paymentIntent = await stripe.paymentIntents.create({
          amount: tier.price,
          currency: currency || 'eur',
          customer: customer_id,
          metadata: {
            membership_tier,
            membership_name: tier.name,
            organization: 'Menschlichkeit Österreich',
          },
          description: `${tier.name} Jahresbeitrag - Menschlichkeit Österreich`,
        });

        return {
          content: [
            {
              type: 'text',
              text: `Payment Intent erstellt:
ID: ${paymentIntent.id}
Betrag: €${tier.price / 100}
Status: ${paymentIntent.status}
Client Secret: ${paymentIntent.client_secret}`,
            },
          ],
        };
      }

      case 'stripe_create_subscription': {
        const { customer_id, membership_tier, payment_method_id } = CreateSubscriptionSchema.parse(args);
        const tier = MEMBERSHIP_TIERS[membership_tier as MembershipTier];
        
        if (tier.price === 0) {
          return {
            content: [
              {
                type: 'text',
                text: `Basis Mitgliedschaft benötigt kein Abonnement - kostenlos für Kunde ${customer_id}`,
              },
            ],
          };
        }

        // Create price for this tier if it doesn't exist
        const price = await stripe.prices.create({
          currency: 'eur',
          unit_amount: tier.price,
          recurring: { interval: 'year' },
          product_data: {
            name: `${tier.name} - Menschlichkeit Österreich`,
          },
          metadata: {
            membership_tier,
            organization: 'Menschlichkeit Österreich',
          },
        });

        const subscription = await stripe.subscriptions.create({
          customer: customer_id,
          items: [{ price: price.id }],
          default_payment_method: payment_method_id,
          metadata: {
            membership_tier,
            membership_name: tier.name,
            organization: 'Menschlichkeit Österreich',
          },
        });

        return {
          content: [
            {
              type: 'text',
              text: `Jahresabonnement erstellt:
ID: ${subscription.id}
Kunde: ${customer_id}
Mitgliedschaft: ${tier.name}
Jahresbeitrag: €${tier.price / 100}
Status: ${subscription.status}`,
            },
          ],
        };
      }

      case 'stripe_get_customer': {
        const { customer_id } = GetCustomerSchema.parse(args);
        
        const customer = await stripe.customers.retrieve(customer_id);
        const subscriptions = await stripe.subscriptions.list({
          customer: customer_id,
          limit: 10,
        });

        if (customer.deleted) {
          return {
            content: [
              {
                type: 'text',
                text: `Kunde wurde gelöscht: ${customer_id}`,
              },
            ],
          };
        }

        return {
          content: [
            {
              type: 'text',
              text: `Kundeninformationen:
ID: ${customer.id}
Email: ${customer.email || 'Nicht angegeben'}
Name: ${customer.name || 'Nicht angegeben'}
Telefon: ${customer.phone || 'Nicht angegeben'}
Mitgliedschaftsstufe: ${customer.metadata?.membership_tier || 'Nicht angegeben'}
Aktive Abonnements: ${subscriptions.data.length}
Erstellt: ${new Date(customer.created * 1000).toLocaleDateString('de-AT')}`,
            },
          ],
        };
      }

      case 'stripe_list_customers': {
        const { limit, starting_after } = ListCustomersSchema.parse(args);
        
        const customers = await stripe.customers.list({
          limit,
          starting_after,
        });

        const customerList = customers.data.map((customer: Stripe.Customer) => {
          if (customer.deleted) return `• ${customer.id} - GELÖSCHT`;
          
          const tier = customer.metadata?.membership_tier as MembershipTier;
          const tierInfo = tier ? MEMBERSHIP_TIERS[tier] : null;
          
          return `• ${customer.name || customer.email} (${customer.id})
  Mitgliedschaft: ${tierInfo?.name || 'Unbekannt'}
  Email: ${customer.email}
  Erstellt: ${new Date(customer.created * 1000).toLocaleDateString('de-AT')}`;
        }).join('\n\n');

        return {
          content: [
            {
              type: 'text',
              text: `Kunden (${customers.data.length} geladen):

${customerList}

${customers.has_more ? `\nWeitere Kunden verfügbar. Verwende starting_after: ${customers.data[customers.data.length - 1].id}` : ''}`,
            },
          ],
        };
      }

      case 'stripe_cancel_subscription': {
        const { subscription_id } = CancelSubscriptionSchema.parse(args);
        
        const subscription = await stripe.subscriptions.cancel(subscription_id);

        return {
          content: [
            {
              type: 'text',
              text: `Abonnement gekündigt:
ID: ${subscription.id}
Status: ${subscription.status}
Gekündigt am: ${subscription.canceled_at ? new Date(subscription.canceled_at * 1000).toLocaleDateString('de-AT') : 'Heute'}`,
            },
          ],
        };
      }

      case 'stripe_list_payments': {
        const limit = (args as any)?.limit || 10;
        
        const charges = await stripe.charges.list({
          limit,
        });

        const paymentList = charges.data.map((charge: Stripe.Charge) => {
          return `• €${charge.amount / 100} - ${charge.status}
  Kunde: ${charge.customer || 'Gast'}
  Beschreibung: ${charge.description || 'Keine Beschreibung'}
  Datum: ${new Date(charge.created * 1000).toLocaleDateString('de-AT')}
  ${charge.paid ? '✅ Bezahlt' : '❌ Nicht bezahlt'}`;
        }).join('\n\n');

        return {
          content: [
            {
              type: 'text',
              text: `Letzte Zahlungen (${charges.data.length}):

${paymentList}`,
            },
          ],
        };
      }

      case 'stripe_get_membership_stats': {
        // Get all customers and their subscriptions
        const customers = await stripe.customers.list({ limit: 100 });
        const activeSubscriptions = await stripe.subscriptions.list({ 
          status: 'active',
          limit: 100 
        });
        
        // Calculate stats
        const tierCounts = { basis: 0, foerderer: 0, unterstuetzer: 0 };
        let monthlyRevenue = 0;
        
        customers.data.forEach((customer: Stripe.Customer) => {
          if (!customer.deleted) {
            const tier = customer.metadata?.membership_tier as MembershipTier;
            if (tier && tierCounts.hasOwnProperty(tier)) {
              tierCounts[tier]++;
            }
          }
        });

        activeSubscriptions.data.forEach((sub: Stripe.Subscription) => {
          const tier = sub.metadata?.membership_tier as MembershipTier;
          if (tier && MEMBERSHIP_TIERS[tier]) {
            monthlyRevenue += MEMBERSHIP_TIERS[tier].price / 12; // Convert annual to monthly
          }
        });

        const annualRevenue = monthlyRevenue * 12;
        const now = Date.now() / 1000;
        const thirtyDaysAgo = now - (30 * 24 * 60 * 60);

        return {
          content: [
            {
              type: 'text',
              text: `📊 Mitgliedschaftsstatistiken - Menschlichkeit Österreich

👥 Mitgliederzahlen:
• Basis Mitglieder: ${tierCounts.basis}
• Förderer: ${tierCounts.foerderer}
• Unterstützer: ${tierCounts.unterstuetzer}
• Gesamt: ${tierCounts.basis + tierCounts.foerderer + tierCounts.unterstuetzer}

💰 Umsatz:
• Aktive Abonnements: ${activeSubscriptions.data.length}
• Geschätzte monatliche Einnahmen: €${(monthlyRevenue / 100).toFixed(2)}
• Geschätzte jährliche Einnahmen: €${(annualRevenue / 100).toFixed(2)}

📈 Wachstum:
• Neue Kunden (letzten 30 Tage): ${customers.data.filter((c: Stripe.Customer) => !c.deleted && c.created > thirtyDaysAgo).length}`,
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
  console.error('Menschlichkeit Österreich Stripe MCP Server gestartet');
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main().catch(console.error);
}

export { server };
