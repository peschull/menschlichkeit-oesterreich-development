/* ==========================================================================
   Democracy Metaverse - Enhanced Mini-Game System
   7 Core Mini-Games with Adaptive Difficulty and Learning Analytics
   ========================================================================== */

class MinigamePool {
  constructor() {
    this.games = new Map();
    this.difficultyAdaptation = new DifficultyAdapter();
    this.analytics = new MinigameAnalytics();
    
    this.registerMinigames();
  }

  registerMinigames() {
    // Register all 7 core mini-games
    this.games.set('fact_check_speedrun', new FactCheckSpeedrun());
    this.games.set('bridge_puzzle', new BridgePuzzle());
    this.games.set('debate_duel', new DebateDuel()); 
    this.games.set('city_simulation', new CitySimulation());
    this.games.set('crisis_council', new CrisisCouncil());
    this.games.set('dialogue_rpg', new DialogueRPG());
    this.games.set('network_analysis', new NetworkAnalysis());
  }

  startMinigame(gameId, context) {
    const game = this.games.get(gameId);
    if (!game) throw new Error(`Minigame ${gameId} not found`);

    // Adapt difficulty based on player performance
    const difficulty = this.difficultyAdaptation.calculateDifficulty(
      gameId, context.playerStats, context.recentPerformance
    );

    // Initialize game with context
    return game.start({
      ...context,
      difficulty: difficulty,
      onComplete: (results) => this.handleCompletion(gameId, results),
      onProgress: (progress) => this.analytics.trackProgress(gameId, progress)
    });
  }
}

/* ==========================================================================
   1. FACT-CHECK SPEEDRUN
   Rapid source verification and bias detection
   ========================================================================== */

class FactCheckSpeedrun {
  constructor() {
    this.timeLimit = 90; // seconds
    this.currentClaims = [];
    this.score = 0;
    this.accuracy = 0;
  }

  start(config) {
    this.difficulty = config.difficulty;
    this.generateClaims(config);
    
    return {
      type: 'fact_check_speedrun',
      title: 'Fakten-Check Speedrun',
      instructions: 'Prüfe so viele Behauptungen wie möglich auf Wahrheitsgehalt!',
      timeLimit: this.timeLimit,
      interface: this.createInterface(),
      scoring: {
        correctFacts: 10,
        correctFakes: 15,
        speedBonus: 5,
        accuracyBonus: 20
      }
    };
  }

  generateClaims(config) {
    const claimTypes = [
      'statistical_manipulation',
      'source_misattribution', 
      'context_stripping',
      'correlation_causation',
      'cherry_picking',
      'deepfake_detection',
      'bot_generated_content'
    ];

    // Generate claims based on current level context
    this.currentClaims = claimTypes
      .slice(0, Math.min(8, 3 + config.difficulty))
      .map(type => this.generateClaim(type, config));
  }

  generateClaim(type, context) {
    const claimDatabase = {
      statistical_manipulation: {
        true: "Die Arbeitslosigkeit ist in den letzten 5 Jahren um 12% gesunken",
        fake: "98% aller Statistiken werden frei erfunden",
        sources: ["Statistik Austria", "AMS Österreich", "OECD Employment Outlook"],
        difficulty: 2
      },
      deepfake_detection: {
        true: "Bundeskanzler hält Rede im Parlament",
        fake: "Bundeskanzler singt Karaoke in seinem Büro", 
        sources: ["ORF Livestream", "Parliament.gv.at", "Suspicious TikTok Account"],
        difficulty: 4,
        requires_visual_analysis: true
      }
    };

    return {
      id: Math.random().toString(36),
      type: type,
      claim: claimDatabase[type][Math.random() > 0.5 ? 'true' : 'fake'],
      isTrue: Math.random() > 0.5,
      sources: claimDatabase[type].sources,
      difficulty: claimDatabase[type].difficulty,
      context: context.currentLevel
    };
  }

  createInterface() {
    return `
      <div class="fact-check-speedrun">
        <div class="timer-display">
          <div class="timer-bar"></div>
          <span class="time-remaining">${this.timeLimit}s</span>
        </div>
        
        <div class="claim-container">
          <div class="claim-text" id="current-claim"></div>
          <div class="source-indicators">
            <div class="source-list" id="available-sources"></div>
            <div class="credibility-meter"></div>
          </div>
        </div>
        
        <div class="fact-check-controls">
          <button class="verdict-btn true" data-verdict="true">
            ✓ Wahr
          </button>
          <button class="verdict-btn fake" data-verdict="false">  
            ✗ Falsch
          </button>
          <button class="skip-btn">
            → Überspringen
          </button>
        </div>
        
        <div class="speedrun-stats">
          <span class="score">Score: <span id="current-score">0</span></span>
          <span class="accuracy">Genauigkeit: <span id="accuracy-rate">100%</span></span>
          <span class="streak">Serie: <span id="current-streak">0</span></span>
        </div>
      </div>
    `;
  }

  handleVerdict(claimId, playerVerdict) {
    const claim = this.currentClaims.find(c => c.id === claimId);
    const correct = (claim.isTrue === playerVerdict);
    
    if (correct) {
      this.score += claim.isTrue ? 10 : 15; // Harder to spot fakes
      this.streak++;
    } else {
      this.streak = 0;
      this.accuracy = this.calculateAccuracy();
    }

    return {
      correct: correct,
      explanation: this.generateExplanation(claim),
      scoreGained: correct ? (claim.isTrue ? 10 : 15) : 0,
      nextClaim: this.getNextClaim()
    };
  }
}

/* ==========================================================================
   2. BRIDGE PUZZLE 
   Connect democratic values while avoiding contradictions
   ========================================================================== */

class BridgePuzzle {
  constructor() {
    this.gridSize = 8;
    this.values = ['E', 'R', 'P', 'Z']; // Empathy, Rights, Participation, Courage
    this.bridges = [];
    this.cracks = [];
  }

  start(config) {
    return {
      type: 'bridge_puzzle',
      title: 'Brücken der Demokratie',
      instructions: 'Verbinde alle Werte-Inseln mit stabilen Brücken!',
      interface: this.createPuzzleGrid(),
      mechanics: {
        drag_and_drop: true,
        physics_simulation: true,
        stress_testing: true
      }
    };
  }

  createPuzzleGrid() {
    return `
      <div class="bridge-puzzle">
        <div class="puzzle-header">
          <div class="construction-materials">
            <div class="material empathy" data-value="E">💜 Empathie</div>
            <div class="material rights" data-value="R">⚖️ Rechte</div>
            <div class="material participation" data-value="P">🗳️ Teilhabe</div>
            <div class="material courage" data-value="Z">🦁 Mut</div>
          </div>
        </div>
        
        <div class="puzzle-grid" id="bridge-grid">
          <!-- 8x8 grid generated dynamically -->
        </div>
        
        <div class="bridge-controls">
          <button class="test-stability">🔧 Stabilität testen</button>
          <button class="clear-bridges">🗑️ Zurücksetzen</button>
          <div class="stability-meter">
            <div class="meter-fill"></div>
            <span class="stability-text">Stabilität: 0%</span>
          </div>
        </div>
      </div>
    `;
  }

  calculateStability(bridges) {
    let totalStability = 0;
    
    bridges.forEach(bridge => {
      // Check for value conflicts
      const conflicts = this.detectValueConflicts(bridge);
      const supportStrength = this.calculateSupport(bridge);
      const connectionQuality = this.analyzeConnections(bridge);
      
      const bridgeStability = (supportStrength + connectionQuality - conflicts) / 3;
      totalStability += Math.max(0, bridgeStability);
    });
    
    return Math.min(100, (totalStability / bridges.length) * 100);
  }

  detectValueConflicts(bridge) {
    // Example: Connecting "Courage" directly to "Rights" without "Empathy" support
    // creates unstable bridge (oversimplified activism)
    const conflictPatterns = {
      'Z-R-no-E': 0.3, // Courage + Rights without Empathy = rigid activism
      'P-E-no-R': 0.2, // Participation + Empathy without Rights = populism risk
      'R-P-no-Z': 0.4  // Rights + Participation without Courage = weak implementation
    };
    
    return this.analyzePattern(bridge, conflictPatterns);
  }
}

/* ==========================================================================
   3. DEBATE DUEL
   Real-time argumentation with fallacy detection
   ========================================================================== */

class DebateDuel {
  constructor() {
    this.turnTimeLimit = 30;
    this.maxRounds = 5;
    this.currentRound = 0;
    this.playerArguments = [];
    this.opponentArguments = [];
  }

  start(config) {
    this.opponent = this.createOpponent(config.bossType || 'populist');
    this.topic = config.debateTopic || this.generateTopic(config);
    
    return {
      type: 'debate_duel',
      title: 'Demokratie-Debatte',
      instructions: 'Überzeuze mit starken Argumenten und entlarve Fehlschlüsse!',
      opponent: this.opponent,
      topic: this.topic,
      interface: this.createDebateInterface()
    };
  }

  createOpponent(type) {
    const opponents = {
      populist: {
        name: "Der Vereinfacher",
        avatar: "👨‍💼",
        tactics: ["false_dichotomy", "ad_hominem", "straw_man"],
        personality: "aggressive",
        weakness: "complexity_exposure"
      },
      demagogue: {
        name: "Die Angstmacherin", 
        avatar: "👩‍⚖️",
        tactics: ["fear_appeal", "slippery_slope", "bandwagon"],
        personality: "manipulative", 
        weakness: "fact_checking"
      },
      lobbyist: {
        name: "Der Interessenvertreter",
        avatar: "👔",
        tactics: ["cherry_picking", "authority_fallacy", "red_herring"],
        personality: "calculating",
        weakness: "transparency_demand"
      }
    };
    
    return opponents[type] || opponents.populist;
  }

  createDebateInterface() {
    return `
      <div class="debate-duel">
        <div class="debate-stage">
          <div class="opponent-side">
            <div class="avatar">${this.opponent.avatar}</div>
            <div class="name">${this.opponent.name}</div>
            <div class="argument-bubble" id="opponent-argument"></div>
          </div>
          
          <div class="vs-indicator">VS</div>
          
          <div class="player-side">
            <div class="avatar">👤</div>
            <div class="name">Du</div>
            <div class="argument-input">
              <textarea placeholder="Dein Argument..." id="player-argument"></textarea>
              <div class="argument-tools">
                <button class="fallacy-detector">🔍 Fehlschluss entlarven</button>
                <button class="fact-check">✓ Fakten prüfen</button>
                <button class="empathy-bridge">💜 Empathie zeigen</button>
              </div>
            </div>
          </div>
        </div>
        
        <div class="debate-progress">
          <div class="round-indicator">Runde ${this.currentRound}/${this.maxRounds}</div>
          <div class="persuasion-meter">
            <div class="meter-bar">
              <div class="player-progress"></div>
              <div class="opponent-progress"></div>
            </div>
            <div class="meter-labels">
              <span>Du</span>
              <span>Publikum</span>
              <span>${this.opponent.name}</span>
            </div>
          </div>
          <div class="time-remaining">${this.turnTimeLimit}s</div>
        </div>
      </div>
    `;
  }

  processArgument(playerArgument, tool) {
    const analysis = this.analyzeArgument(playerArgument);
    const toolEffectiveness = this.calculateToolEffect(tool, analysis);
    const opponentResponse = this.generateOpponentResponse(playerArgument, tool);
    
    return {
      argumentStrength: analysis.strength,
      toolEffect: toolEffectiveness,
      audienceReaction: this.calculateAudienceReaction(analysis, toolEffectiveness),
      opponentResponse: opponentResponse,
      roundWinner: this.determineRoundWinner(analysis, opponentResponse)
    };
  }
}

/* ==========================================================================
   4. CITY SIMULATION
   Resource management with stakeholder balance
   ========================================================================== */

class CitySimulation {
  constructor() {
    this.budget = 1000000; // 1 Million Euro
    this.satisfaction = {
      citizens: 50,
      business: 50, 
      environment: 50,
      future_generations: 50
    };
    this.projects = [];
  }

  start(config) {
    this.scenario = config.scenario || 'budget_allocation';
    this.timeLimit = config.timeLimit || 300; // 5 minutes
    
    return {
      type: 'city_simulation',
      title: 'Stadt der Zukunft',
      instructions: 'Verwalte das Budget gerecht und nachhaltig!',
      interface: this.createSimInterface(),
      realTime: true
    };
  }

  createSimInterface() {
    return `
      <div class="city-simulation">
        <div class="city-overview">
          <div class="budget-display">
            💰 Budget: <span id="remaining-budget">${this.budget.toLocaleString()}€</span>
          </div>
          <div class="satisfaction-dashboard">
            <div class="satisfaction-meter citizens">
              👥 Bürger*innen: <span class="meter-bar"><span style="width: 50%"></span></span> 50%
            </div>
            <div class="satisfaction-meter business">
              🏢 Wirtschaft: <span class="meter-bar"><span style="width: 50%"></span></span> 50%
            </div>
            <div class="satisfaction-meter environment">
              🌱 Umwelt: <span class="meter-bar"><span style="width: 50%"></span></span> 50%
            </div>
            <div class="satisfaction-meter future">
              👶 Zukunft: <span class="meter-bar"><span style="width: 50%"></span></span> 50%
            </div>
          </div>
        </div>
        
        <div class="project-selection">
          <h3>Verfügbare Projekte</h3>
          <div class="project-cards" id="available-projects">
            <!-- Generated dynamically based on scenario -->
          </div>
        </div>
        
        <div class="stakeholder-feedback">
          <div class="feedback-panel" id="live-feedback">
            <!-- Real-time reactions from different groups -->
          </div>
        </div>
      </div>
    `;
  }

  generateProjects(scenario) {
    const projectDatabase = {
      budget_allocation: [
        {
          name: "Neue Fahrradwege",
          cost: 200000,
          effects: { citizens: +15, environment: +20, business: -5, future: +10 },
          description: "Nachhaltige Mobilität fördern"
        },
        {
          name: "Wirtschaftsförderung",
          cost: 300000,
          effects: { citizens: +5, environment: -10, business: +25, future: -5 },
          description: "Arbeitsplätze schaffen"
        },
        {
          name: "Soziale Wohnungen", 
          cost: 400000,
          effects: { citizens: +20, environment: 0, business: -10, future: +5 },
          description: "Bezahlbaren Wohnraum schaffen"
        }
        // ... more projects
      ]
    };
    
    return projectDatabase[scenario] || [];
  }
}

/* ==========================================================================
   5-7. Additional Mini-Games (Crisis Council, Dialogue RPG, Network Analysis)
   Following similar patterns with specialized mechanics
   ========================================================================== */

class CrisisCouncil {
  // Emergency decision-making under pressure
  // Resource scarcity + time pressure + competing needs
}

class DialogueRPG {
  // Character-driven conversations with emotion tracking
  // Branching narratives based on empathy choices
}

class NetworkAnalysis {
  // Social network visualization and manipulation detection
  // Bot identification, echo chamber mapping, influence tracking
}

/* ==========================================================================
   ADAPTIVE DIFFICULTY SYSTEM
   ========================================================================== */

class DifficultyAdapter {
  calculateDifficulty(gameId, playerStats, recentPerformance) {
    const baseLevel = Math.floor((playerStats.E + playerStats.R + playerStats.P + playerStats.Z) / 20);
    const performanceModifier = this.analyzePerformance(recentPerformance);
    const gameSpecificModifier = this.getGameModifier(gameId, playerStats);
    
    return Math.max(1, Math.min(5, baseLevel + performanceModifier + gameSpecificModifier));
  }
  
  analyzePerformance(performance) {
    if (!performance || performance.length === 0) return 0;
    
    const averageScore = performance.reduce((sum, p) => sum + p.score, 0) / performance.length;
    const averageTime = performance.reduce((sum, p) => sum + p.completionTime, 0) / performance.length;
    
    // Increase difficulty if consistently high performance
    if (averageScore > 0.8 && averageTime < 60) return 1;
    if (averageScore < 0.4 || averageTime > 180) return -1;
    
    return 0;
  }
}

/* ==========================================================================
   LEARNING ANALYTICS
   ========================================================================== */

class MinigameAnalytics {
  trackProgress(gameId, progress) {
    // GDPR-compliant learning analytics
    const anonymizedData = {
      game: gameId,
      timestamp: Date.now(),
      progress: progress.percentage,
      decisions: progress.decisions?.length || 0,
      hintsUsed: progress.hintsUsed || 0,
      errorPatterns: this.categorizeErrors(progress.errors)
    };
    
    // Store locally for immediate feedback
    this.storeLocal(anonymizedData);
    
    // Optional: Send to learning analytics service (with consent)
    if (this.hasAnalyticsConsent()) {
      this.sendToLearningService(anonymizedData);
    }
  }
  
  generatePersonalizedFeedback(gameId, results) {
    return {
      strengths: this.identifyStrengths(results),
      improvements: this.suggestImprovements(results), 
      nextSteps: this.recommendNextSteps(gameId, results),
      transferTips: this.generateTransferTips(results)
    };
  }
}

// Export for use in main game system
export { MinigamePool, FactCheckSpeedrun, BridgePuzzle, DebateDuel, CitySimulation };