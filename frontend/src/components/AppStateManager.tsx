type AppState = {
  isAuthenticated: boolean;
};

export function useAppState() {
  const state: AppState = { isAuthenticated: false };
  const openModal = (type: string, sub?: string) => {
    if (typeof window !== 'undefined') {
      // placeholder: integrate real modal system later
      console.debug('openModal called', { type, sub });
    }
  };
  return { state, openModal };
}
