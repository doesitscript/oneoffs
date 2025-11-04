#!/usr/bin/env node

/**
 * Evidence Validator MCP Server
 * Provides context-aware evidence validation for claims
 */

const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} = require('@modelcontextprotocol/sdk/types.js');

class EvidenceValidatorServer {
  constructor() {
    this.server = new Server(
      {
        name: 'evidence-validator',
        version: '1.0.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );

    this.setupToolHandlers();
  }

  setupToolHandlers() {
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: 'validate_evidence_claim',
            description: 'Validates claims only when evidence is required (context-aware)',
            inputSchema: {
              type: 'object',
              properties: {
                context: {
                  type: 'string',
                  description: 'Context of the request (evaluation/status/verification vs normal task)',
                  enum: ['evaluation', 'status', 'verification', 'normal_task']
                },
                claim: {
                  type: 'string',
                  description: 'The claim being made'
                },
                evidence: {
                  type: 'string',
                  description: 'The evidence supporting the claim (command + output + timestamp)'
                },
                trigger_phrases: {
                  type: 'array',
                  items: { type: 'string' },
                  description: 'User phrases that triggered evidence requirement'
                }
              },
              required: ['context', 'claim']
            }
          },
          {
            name: 'check_evidence_required',
            description: 'Checks if evidence is required based on user request context',
            inputSchema: {
              type: 'object',
              properties: {
                user_request: {
                  type: 'string',
                  description: 'The user\'s request or question'
                }
              },
              required: ['user_request']
            }
          }
        ],
      };
    });

    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      switch (name) {
        case 'validate_evidence_claim':
          return await this.validateEvidenceClaim(args);
        case 'check_evidence_required':
          return await this.checkEvidenceRequired(args);
        default:
          throw new Error(`Unknown tool: ${name}`);
      }
    });
  }

  async validateEvidenceClaim(args) {
    const { context, claim, evidence, trigger_phrases } = args;

    // Evidence is required for evaluation/status/verification contexts
    const evidenceRequired = ['evaluation', 'status', 'verification'].includes(context);

    // Check for Playwright usage violations
    if (claim && claim.toLowerCase().includes('playwright') && !evidence.includes('explicit user permission')) {
      return {
        content: [
          {
            type: 'text',
            text: `❌ PLAYWRIGHT VIOLATION: Playwright usage detected without explicit user permission. Use macOS automation instead.`
          }
        ]
      };
    }

    // Check for non-terminating error reporting violations
    if (evidence && evidence.includes('Script execution failed') && !evidence.includes('ERROR TYPE')) {
      return {
        content: [
          {
            type: 'text',
            text: `❌ NON-TERMINATING ERROR VIOLATION: Script execution failure detected but not properly reported with ERROR TYPE format. Must report non-terminating errors immediately with full context.`
          }
        ]
      };
    }

    if (evidenceRequired && !evidence) {
      return {
        content: [
          {
            type: 'text',
            text: `❌ EVIDENCE REQUIRED: Claim "${claim}" requires evidence in context "${context}"`
          }
        ]
      };
    }

    if (evidenceRequired && evidence) {
      return {
        content: [
          {
            type: 'text',
            text: `✅ EVIDENCE PROVIDED: Claim "${claim}" supported by evidence in context "${context}"`
          }
        ]
      };
    }

    return {
      content: [
        {
          type: 'text',
          text: `ℹ️ NO EVIDENCE REQUIRED: Context "${context}" does not require evidence validation`
        }
      ]
    };
  }

  async checkEvidenceRequired(args) {
    const { user_request } = args;

    // Trigger phrases that require evidence
    const evidenceTriggers = [
      'evaluate', 'status', 'verify', 'check', 'did it work', 'is it working',
      'what happened', 'show me proof', 'back up your claim', 'prove it',
      'evidence', 'logs', 'console', 'screenshot', 'result'
    ];

    const lowerRequest = user_request.toLowerCase();
    const requiresEvidence = evidenceTriggers.some(trigger =>
      lowerRequest.includes(trigger)
    );

    const matchedTriggers = evidenceTriggers.filter(trigger =>
      lowerRequest.includes(trigger)
    );

    return {
      content: [
        {
          type: 'text',
          text: JSON.stringify({
            requires_evidence: requiresEvidence,
            context: requiresEvidence ? 'evaluation' : 'normal_task',
            matched_triggers: matchedTriggers,
            recommendation: requiresEvidence
              ? 'Use CLAIM → EVIDENCE → STATUS format'
              : 'Normal task - no evidence required'
          }, null, 2)
        }
      ]
    };
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('Evidence Validator MCP server running on stdio');
  }
}

const server = new EvidenceValidatorServer();
server.run().catch(console.error);
