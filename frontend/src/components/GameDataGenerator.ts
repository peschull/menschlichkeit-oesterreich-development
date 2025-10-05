export type GameLevel = { id: number; title: string; description?: string };
export type Chapter = { id: number; title: string; levelRange: [number, number] };
export type MinigameData = { id: number; name: string };
export type BossData = { id: number; name: string };

const GameDataGenerator = {
  generateChapters(): Chapter[] {
    return [
      { id: 1, title: 'Einführung', levelRange: [1, 20] },
      { id: 2, title: 'Vertiefung', levelRange: [21, 40] },
      { id: 3, title: 'Herausforderung', levelRange: [41, 60] },
      { id: 4, title: 'Fortgeschritten', levelRange: [61, 80] },
      { id: 5, title: 'Meisterschaft', levelRange: [81, 100] },
    ];
  },
  generateChapter1Levels(): GameLevel[] {
    return Array.from({ length: 20 }, (_, i) => ({ id: i + 1, title: `Level ${i + 1}` }));
  },
};

export default GameDataGenerator;

