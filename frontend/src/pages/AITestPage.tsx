// AI Integration Test Page
import React from 'react';
import { AIIntegrationDemo } from '../components/demo/AIIntegrationDemo';
import { AuthSystem } from '../components/auth/AuthSystem';
import { SepaManagement } from '../components/sepa/SepaManagement';
import { PrivacyCenter } from '../components/privacy/PrivacyCenter';
import { SecurityDashboard } from '../components/security/SecurityDashboard';

/**
 * Test Page für alle AI-integrierten Komponenten
 * Zeigt ChatGPT/Codex Integration in Aktion
 */
export const AITestPage: React.FC = () => {
  const [activeDemo, setActiveDemo] = React.useState<
    'ai-demo' | 'auth' | 'sepa' | 'privacy' | 'security'
  >('ai-demo');

  const demos = [
    { id: 'ai-demo' as const, title: 'AI Integration Demo', icon: 'bi-robot' },
    { id: 'auth' as const, title: 'Auth System', icon: 'bi-shield-lock' },
    { id: 'sepa' as const, title: 'SEPA Management', icon: 'bi-bank' },
    { id: 'privacy' as const, title: 'Privacy Center', icon: 'bi-shield-check' },
    { id: 'security' as const, title: 'Security Dashboard', icon: 'bi-speedometer2' },
  ];

  return (
    <div className="min-h-screen bg-neutral-50">
      {/* Header */}
      <div className="bg-white border-b border-border">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 bg-gradient-to-r from-red-500 to-orange-500 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-sm">M🇦🇹</span>
              </div>
              <h1 className="text-xl font-bold">Menschlichkeit Österreich - AI Integration Test</h1>
            </div>

            <div className="flex items-center gap-2 text-sm text-muted">
              <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
              <span>ChatGPT + Codex + Copilot Active</span>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Navigation */}
        <div className="flex flex-wrap gap-2 mb-8">
          {demos.map(demo => (
            <button
              key={demo.id}
              onClick={() => setActiveDemo(demo.id)}
              className={`
                flex items-center gap-2 px-4 py-2 rounded-lg transition-colors
                ${
                  activeDemo === demo.id
                    ? 'bg-primary-500 text-white'
                    : 'bg-white text-text hover:bg-surface-elevated border border-border'
                }
              `}
            >
              <i className={demo.icon} aria-hidden="true"></i>
              <span>{demo.title}</span>
            </button>
          ))}
        </div>

        {/* Demo Content */}
        <div className="bg-white rounded-lg border border-border min-h-96">
          {activeDemo === 'ai-demo' && <AIIntegrationDemo />}

          {activeDemo === 'auth' && (
            <div className="p-8">
              <h2 className="text-2xl font-bold mb-4">🔐 Authentication System Demo</h2>
              <p className="text-muted mb-6">
                KI-generierte Authentication mit 2FA, österreichischen DSGVO-Standards und
                Vereins-Rollensystem.
              </p>
              <AuthSystem isOpen={true} onClose={() => {}} />
            </div>
          )}

          {activeDemo === 'sepa' && (
            <div className="p-8">
              <h2 className="text-2xl font-bold mb-4">🏦 SEPA Management Demo</h2>
              <p className="text-muted mb-6">
                KI-optimierte SEPA-Lastschrift mit österreichischen Banken und DSGVO-Compliance.
              </p>
              <SepaManagement
                onComplete={mandate => console.log('SEPA Mandat erstellt:', mandate)}
              />
            </div>
          )}

          {activeDemo === 'privacy' && (
            <div className="p-8">
              <h2 className="text-2xl font-bold mb-4">🛡️ Privacy Center Demo</h2>
              <p className="text-muted mb-6">
                KI-unterstütztes DSGVO-Compliance Center für österreichische Vereine.
              </p>
              <PrivacyCenter isOpen={true} onClose={() => {}} />
            </div>
          )}

          {activeDemo === 'security' && (
            <div className="p-8">
              <h2 className="text-2xl font-bold mb-4">🚨 Security Dashboard Demo</h2>
              <p className="text-muted mb-6">
                KI-powered Security-Monitoring mit österreichischen Compliance-Standards.
              </p>
              <SecurityDashboard />
            </div>
          )}
        </div>

        {/* Footer Info */}
        <div className="mt-8 p-4 bg-gradient-to-r from-blue-50 to-green-50 rounded-lg border border-blue-200">
          <div className="flex items-start gap-3">
            <i className="bi bi-lightbulb text-blue-600 text-xl mt-0.5" aria-hidden="true"></i>
            <div>
              <h3 className="font-semibold text-blue-900 mb-2">🚀 KI-Integration Features</h3>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm text-blue-800">
                <div>
                  <strong>ChatGPT Extension:</strong>
                  <ul className="ml-4 mt-1 space-y-1">
                    <li>• Österreich-spezifische Prompts</li>
                    <li>• DSGVO-konforme Code-Generierung</li>
                    <li>• Terminal-Integration</li>
                    <li>• Multi-File Editing</li>
                  </ul>
                </div>
                <div>
                  <strong>OpenAI Codex:</strong>
                  <ul className="ml-4 mt-1 space-y-1">
                    <li>• Inline Code Completion</li>
                    <li>• Workspace-Indexierung</li>
                    <li>• SEPA-Banking Integration</li>
                    <li>• Security-Review Automation</li>
                  </ul>
                </div>
                <div>
                  <strong>GitHub Copilot:</strong>
                  <ul className="ml-4 mt-1 space-y-1">
                    <li>• Custom Instructions Files</li>
                    <li>• Prompt Files für Workflows</li>
                    <li>• Chat Modes (Plan/Frontend)</li>
                    <li>• Vereins-optimierte Settings</li>
                  </ul>
                </div>
                <div>
                  <strong>Sprint 1 Integration:</strong>
                  <ul className="ml-4 mt-1 space-y-1">
                    <li>• Auth & Security System</li>
                    <li>• SEPA-Management Ende-zu-Ende</li>
                    <li>• DSGVO Privacy Center</li>
                    <li>• Security Dashboard</li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AITestPage;
