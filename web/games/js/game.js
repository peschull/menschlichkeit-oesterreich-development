/* ==========================================================================
   Brücken Bauen - Main Game Logic
   Interactive Democracy Game Controller
   ========================================================================== */

class DemocracyGame {
  constructor() {
    this.currentScenario = 0;
    this.gameState = {
      scenarios: [...SCENARIOS],
      scores: {
        empathy: 0,
        rights: 0,
        participation: 0,
        courage: 0
      },
      decisions: [],
      startTime: null,
      totalScore: 0,
      profile: null
    };
    
    this.maxPossibleScore = SCENARIOS.length * 12; // 4 categories × 3 max points
    this.ui = new GameUI(this);
    
    this.init();
  }

  init() {
    console.log('🌉 Brücken Bauen - Democracy Game initialized');
    this.setupEventListeners();
    this.showStartScreen();
    
    // Initialize accessibility announcements
    this.announcements = document.getElementById('announcements');
    
    // Track analytics (privacy-friendly)
    this.trackGameStart();
  }

  setupEventListeners() {
    // Start button
    const startBtn = document.getElementById('start-game-btn');
    if (startBtn) {
      startBtn.addEventListener('click', () => this.startGame());
    }

    // Decision submission
    const submitBtn = document.getElementById('submit-decision-btn');
    if (submitBtn) {
      submitBtn.addEventListener('click', () => this.submitDecision());
    }

    // Continue button
    const continueBtn = document.getElementById('continue-btn');
    if (continueBtn) {
      continueBtn.addEventListener('click', () => this.nextScenario());
    }

    // Final screen buttons
    const restartBtn = document.getElementById('restart-btn');
    if (restartBtn) {
      restartBtn.addEventListener('click', () => this.restartGame());
    }

    const shareBtn = document.getElementById('share-btn');
    if (shareBtn) {
      shareBtn.addEventListener('click', () => this.shareGame());
    }

    // Keyboard navigation
    document.addEventListener('keydown', (e) => this.handleKeyboard(e));
    
    // Decision option clicks
    this.setupDecisionHandlers();
  }

  setupDecisionHandlers() {
    const decisionContainer = document.getElementById('decision-options');
    if (decisionContainer) {
      decisionContainer.addEventListener('click', (e) => {
        if (e.target.classList.contains('decision-option')) {
          this.selectDecision(e.target.dataset.decisionId);
        }
      });

      decisionContainer.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          if (e.target.classList.contains('decision-option')) {
            e.preventDefault();
            this.selectDecision(e.target.dataset.decisionId);
          }
        }
      });
    }
  }

  showStartScreen() {
    this.ui.showScreen('start');
    this.ui.updateProgress(0, SCENARIOS.length);
    this.announce('Willkommen bei Brücken Bauen - dem interaktiven Demokratie-Lernspiel');
  }

  startGame() {
    this.gameState.startTime = new Date();
    this.currentScenario = 0;
    this.resetScores();
    
    this.ui.showLoadingScreen(true);
    
    setTimeout(() => {
      this.ui.showLoadingScreen(false);
      this.loadScenario();
      this.trackScenarioStart(1);
    }, 1000);
  }

  resetScores() {
    this.gameState.scores = {
      empathy: 0,
      rights: 0,
      participation: 0,
      courage: 0
    };
    this.gameState.decisions = [];
    this.gameState.totalScore = 0;
  }

  loadScenario() {
    if (this.currentScenario >= SCENARIOS.length) {
      this.endGame();
      return;
    }

    const scenario = SCENARIOS[this.currentScenario];
    this.ui.showScreen('game');
    this.ui.updateProgress(this.currentScenario + 1, SCENARIOS.length);
    this.ui.renderScenario(scenario);
    
    this.announce(`Szenario ${this.currentScenario + 1}: ${scenario.title}`);
    
    // Reset decision state
    this.selectedDecision = null;
    this.ui.updateSubmitButton(false);
  }

  selectDecision(decisionId) {
    const scenario = SCENARIOS[this.currentScenario];
    const decision = scenario.decisions.find(d => d.id === decisionId);
    
    if (!decision) return;

    this.selectedDecision = decision;
    
    // Update UI
    this.ui.selectDecisionOption(decisionId);
    this.ui.updateSubmitButton(true);
    
    this.announce(`Entscheidung ausgewählt: ${decision.text}`);
  }

  submitDecision() {
    if (!this.selectedDecision) return;

    const scenario = SCENARIOS[this.currentScenario];
    
    // Update scores
    this.updateScores(this.selectedDecision.scores);
    
    // Save decision
    this.gameState.decisions.push({
      scenarioId: scenario.id,
      decisionId: this.selectedDecision.id,
      decision: this.selectedDecision,
      timestamp: new Date()
    });

    // Show result
    this.showResult(scenario, this.selectedDecision);
    
    // Track analytics
    this.trackDecision(scenario.id, this.selectedDecision.id);
  }

  updateScores(newScores) {
    this.gameState.scores.empathy += newScores.empathy;
    this.gameState.scores.rights += newScores.rights;
    this.gameState.scores.participation += newScores.participation;
    this.gameState.scores.courage += newScores.courage;
    
    this.gameState.totalScore = Object.values(this.gameState.scores)
      .reduce((sum, score) => sum + score, 0);
  }

  showResult(scenario, decision) {
    this.ui.showScreen('result');
    this.ui.renderResult(scenario, decision, this.gameState.scores, this.maxPossibleScore);
    
    this.announce(`Ergebnis: ${decision.feedback}`);
    
    // Update continue button text
    const continueBtn = document.getElementById('continue-btn');
    if (continueBtn) {
      if (this.currentScenario >= SCENARIOS.length - 1) {
        continueBtn.textContent = 'Zum Ergebnis';
        continueBtn.innerHTML = `
          <svg class="button-icon" width="20" height="20" viewBox="0 0 20 20" aria-hidden="true">
            <path d="M10 2L13 8h5l-4 6 1 4-5-3-5 3 1-4-4-6h5l3-6z" fill="currentColor"/>
          </svg>
          Zum Ergebnis
        `;
      } else {
        continueBtn.textContent = 'Weiter zum nächsten Szenario';
      }
    }
  }

  nextScenario() {
    this.currentScenario++;
    
    if (this.currentScenario >= SCENARIOS.length) {
      this.endGame();
    } else {
      this.ui.showLoadingScreen(true);
      
      setTimeout(() => {
        this.ui.showLoadingScreen(false);
        this.loadScenario();
        this.trackScenarioStart(this.currentScenario + 1);
      }, 500);
    }
  }

  endGame() {
    // Calculate final profile
    this.gameState.profile = getDemocracyProfile(
      this.gameState.totalScore, 
      this.maxPossibleScore
    );
    
    this.ui.showScreen('final');
    this.ui.renderFinalResult(this.gameState);
    
    this.announce(`Spiel beendet! Du bist ein ${this.gameState.profile.title}`);
    
    // Track completion
    this.trackGameComplete();
  }

  restartGame() {
    this.currentScenario = 0;
    this.resetScores();
    this.showStartScreen();
    this.trackGameRestart();
  }

  shareGame() {
    if (navigator.share) {
      navigator.share({
        title: 'Brücken Bauen - Democracy Game',
        text: `Ich habe das Demokratie-Lernspiel gespielt und bin ein ${this.gameState.profile.title}! 🌉`,
        url: window.location.href
      });
    } else {
      // Fallback for browsers without native sharing
      const shareText = `Ich habe das Demokratie-Lernspiel "Brücken Bauen" gespielt und bin ein ${this.gameState.profile.title}! 🌉 ${window.location.href}`;
      
      if (navigator.clipboard) {
        navigator.clipboard.writeText(shareText).then(() => {
          this.announce('Link wurde in die Zwischenablage kopiert!');
        });
      } else {
        // Ultra-fallback
        const textArea = document.createElement('textarea');
        textArea.value = shareText;
        document.body.appendChild(textArea);
        textArea.select();
        document.execCommand('copy');
        document.body.removeChild(textArea);
        this.announce('Link wurde in die Zwischenablage kopiert!');
      }
    }
    
    this.trackShare();
  }

  handleKeyboard(e) {
    // ESC key - return to start
    if (e.key === 'Escape' && this.currentScenario > 0) {
      if (confirm('Möchtest du das Spiel wirklich verlassen?')) {
        this.showStartScreen();
      }
    }
    
    // Arrow keys for decision navigation
    if (e.key === 'ArrowUp' || e.key === 'ArrowDown') {
      this.navigateDecisions(e.key === 'ArrowUp' ? -1 : 1);
      e.preventDefault();
    }
    
    // Enter key for quick actions
    if (e.key === 'Enter') {
      const activeScreen = document.querySelector('.screen.active');
      if (activeScreen.id === 'start-screen') {
        const startBtn = document.getElementById('start-game-btn');
        if (startBtn && document.activeElement !== startBtn) {
          startBtn.click();
        }
      }
    }
  }

  navigateDecisions(direction) {
    const options = document.querySelectorAll('.decision-option');
    if (options.length === 0) return;
    
    const currentIndex = Array.from(options).findIndex(option => 
      document.activeElement === option
    );
    
    let nextIndex = currentIndex + direction;
    if (nextIndex < 0) nextIndex = options.length - 1;
    if (nextIndex >= options.length) nextIndex = 0;
    
    options[nextIndex].focus();
  }

  announce(message) {
    if (this.announcements) {
      this.announcements.textContent = message;
      
      // Clear after 3 seconds
      setTimeout(() => {
        this.announcements.textContent = '';
      }, 3000);
    }
  }

  // Analytics methods (privacy-friendly, no personal data)
  trackGameStart() {
    if (typeof gtag === 'function') {
      gtag('event', 'game_start', {
        'event_category': 'democracy_game',
        'event_label': 'bruecken_bauen'
      });
    }
  }

  trackScenarioStart(scenarioNumber) {
    if (typeof gtag === 'function') {
      gtag('event', 'scenario_start', {
        'event_category': 'democracy_game',
        'event_label': `scenario_${scenarioNumber}`
      });
    }
  }

  trackDecision(scenarioId, decisionId) {
    if (typeof gtag === 'function') {
      gtag('event', 'decision_made', {
        'event_category': 'democracy_game',
        'event_label': `scenario_${scenarioId}_decision_${decisionId}`
      });
    }
  }

  trackGameComplete() {
    const playTime = new Date() - this.gameState.startTime;
    const minutes = Math.round(playTime / 60000);
    
    if (typeof gtag === 'function') {
      gtag('event', 'game_complete', {
        'event_category': 'democracy_game',
        'event_label': this.gameState.profile.title,
        'value': this.gameState.totalScore,
        'custom_parameter_1': minutes // play time in minutes
      });
    }
  }

  trackGameRestart() {
    if (typeof gtag === 'function') {
      gtag('event', 'game_restart', {
        'event_category': 'democracy_game'
      });
    }
  }

  trackShare() {
    if (typeof gtag === 'function') {
      gtag('event', 'share', {
        'event_category': 'democracy_game',
        'event_label': 'game_result'
      });
    }
  }

  // Debug methods (only in development)
  debugGameState() {
    console.log('🔍 Game State:', this.gameState);
    console.log('🎯 Current Scenario:', this.currentScenario);
    console.log('📊 Scores:', this.gameState.scores);
    console.log('🏆 Total Score:', this.gameState.totalScore, '/', this.maxPossibleScore);
    
    if (this.gameState.profile) {
      console.log('👤 Profile:', this.gameState.profile.title);
    }
  }

  // Export game data (for educational analysis)
  exportGameData() {
    const exportData = {
      timestamp: new Date().toISOString(),
      gameVersion: '1.0',
      totalScore: this.gameState.totalScore,
      maxPossibleScore: this.maxPossibleScore,
      profile: this.gameState.profile?.title,
      scores: { ...this.gameState.scores },
      decisions: this.gameState.decisions.map(d => ({
        scenarioId: d.scenarioId,
        decisionId: d.decisionId,
        scores: d.decision.scores
      })),
      playTime: this.gameState.startTime ? 
        new Date() - this.gameState.startTime : null
    };
    
    return exportData;
  }
}

// Auto-initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  window.democracyGame = new DemocracyGame();
  
  // Expose debug methods in development
  if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
    window.debugGame = () => window.democracyGame.debugGameState();
    window.exportGame = () => window.democracyGame.exportGameData();
    console.log('🔧 Debug mode: Use debugGame() and exportGame() in console');
  }
});