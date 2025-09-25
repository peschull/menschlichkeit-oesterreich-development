import React from 'react';
import { NavLink } from 'react-router-dom';
import { Button } from './Button';
import { useAuth } from '../../auth/AuthContext';

export function Navigation() {
  const { token, logout } = useAuth();
  const [open, setOpen] = React.useState(false);
  const [scrolled, setScrolled] = React.useState(false);

  React.useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 0);
    onScroll();
    window.addEventListener('scroll', onScroll);
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  return (
    <header className={[
      'sticky top-0 z-[var(--ds-z-index-sticky)] bg-semantic-background',
      'border-b border-semantic-border',
      scrolled ? 'shadow-sm' : '',
    ].join(' ')}>
      <a href="#main" className="sr-only focus:not-sr-only focus:absolute focus:inset-x-0 focus:top-0 focus:m-2 focus:rounded-md focus:bg-secondary-50 focus:p-2">
        Zum Inhalt springen
      </a>
      <nav aria-label="Hauptnavigation">
        <div className="mx-auto flex max-w-5xl items-center justify-between px-4 py-3">
          <div className="flex items-center gap-6">
            <NavLink to="/" className="text-primary-700 font-semibold">
              MOE App
            </NavLink>
            <div className="hidden md:flex items-center gap-4">
              <NavLink to="/" className={({ isActive }) => isActive ? 'text-primary-700' : 'text-secondary-700'}>
                Home
              </NavLink>
              <NavLink to="/member" className={({ isActive }) => isActive ? 'text-primary-700' : 'text-secondary-700'}>
                Member‑Area
              </NavLink>
            </div>
          </div>
          <div className="hidden md:flex items-center gap-2">
            <Button
              variant="secondary"
              aria-label="Theme umschalten"
              onClick={() => {
                const root = document.documentElement;
                root.dataset.theme = root.dataset.theme === 'dark' ? 'light' : 'dark';
              }}
            >
              Theme
            </Button>
            {token ? (
              <Button variant="ghost" onClick={logout}>Logout</Button>
            ) : (
              <NavLink to="/login" className="text-primary-700">Login</NavLink>
            )}
          </div>
          <div className="md:hidden">
            <Button
              variant="outline"
              aria-haspopup="menu"
              aria-expanded={open}
              aria-controls="mobile-menu"
              onClick={() => setOpen(!open)}
            >
              Menü
            </Button>
          </div>
        </div>
        {/* Mobile Menu */}
        {open && (
          <div className="md:hidden relative">
            <div
              className="fixed inset-0 bg-semantic-overlay"
              aria-hidden="true"
              onClick={() => setOpen(false)}
            />
            <div
              id="mobile-menu"
              role="menu"
              aria-label="Mobiles Menü"
              className="fixed right-0 top-0 h-full w-72 max-w-[80%] translate-x-0 bg-white p-4 shadow-lg"
            >
              <div className="mb-4 flex items-center justify-between">
                <span className="text-primary-700 font-semibold">Menü</span>
                <Button variant="ghost" aria-label="Menü schließen" onClick={() => setOpen(false)}>Schließen</Button>
              </div>
              <div className="flex flex-col gap-3" onClick={() => setOpen(false)}>
                <NavLink to="/" className="text-secondary-800">Home</NavLink>
                <NavLink to="/member" className="text-secondary-800">Member‑Area</NavLink>
                <hr className="border-semantic-border" />
                <Button
                  variant="secondary"
                  onClick={() => {
                    const root = document.documentElement;
                    root.dataset.theme = root.dataset.theme === 'dark' ? 'light' : 'dark';
                  }}
                >
                  Theme wechseln
                </Button>
                {token ? (
                  <Button variant="outline" onClick={logout}>Logout</Button>
                ) : (
                  <NavLink to="/login" className="text-primary-700">Login</NavLink>
                )}
              </div>
            </div>
          </div>
        )}
      </nav>
    </header>
  );
}
