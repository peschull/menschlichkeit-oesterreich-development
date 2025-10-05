import { lazy, Suspense, useEffect, useState } from 'react';
import { Navigation } from './components/Navigation';
import { Hero } from './components/Hero';
import { About } from './components/About';
import { Themes } from './components/Themes';
import { Footer } from './components/Footer';
import { AppStateProvider, useAppState } from './components/AppStateManager';
import { ModalManager } from './components/ModalManager';
import { PWAInstaller } from './components/PWAInstaller';
import { ErrorBoundary } from './components/ErrorBoundary';
import { ServiceWorkerRegistration } from './components/ServiceWorkerRegistration';
import { ToastProvider } from './components/ToastProvider';
import { CookieConsent } from './components/CookieConsent';
import { BackToTop } from './components/BackToTop';
import { ScrollProgress } from './components/ScrollProgress';
import { SEOHead, NGOStructuredData } from './components/SEOHead';
import { LoadingSpinner } from './components/LoadingSpinner';
import { motion, AnimatePresence } from 'motion/react';

// Lazy load heavy components
const DemocracyGameHub = lazy(() => import('./components/DemocracyGameHub'));
const BridgeBuilding = lazy(() => import('./components/BridgeBuilding'));
const BridgeBuilding100 = lazy(() => import('./components/BridgeBuilding100'));
const Forum = lazy(() => import('./components/Forum'));
const Join = lazy(() => import('./components/Join'));
const Donate = lazy(() => import('./components/Donate'));
const Events = lazy(() => import('./components/Events'));
const News = lazy(() => import('./components/News'));
const Contact = lazy(() => import('./components/Contact'));
const AdminDashboard = lazy(() => import('./components/AdminDashboard'));

function AppContent() {
  const { state, openModal, logout } = useAppState();
  const [isOnline, setIsOnline] = useState(true);

  // Online/Offline detection
  useEffect(() => {
    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);

    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);

  return (
    <div className="min-h-screen relative">
      <SEOHead />
      <NGOStructuredData />

      {/* Offline Indicator */}
      <AnimatePresence>
        {!isOnline && (
          <motion.div
            initial={{ y: -100 }}
            animate={{ y: 0 }}
            exit={{ y: -100 }}
            className="fixed top-0 left-0 right-0 bg-warning text-warning-foreground px-4 py-2 text-center z-[100] shadow-lg"
          >
            <span className="text-sm font-medium">
              ⚠️ Keine Internetverbindung
            </span>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Skip Navigation */}
      <a
        href="#main-content"
        className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 bg-primary text-primary-foreground px-4 py-2 rounded-md z-50"
      >
        Zum Hauptinhalt springen
      </a>

      <Navigation
        isAuthenticated={state.isAuthenticated}
        user={state.user}
        onLogin={() => openModal('auth', 'login')}
        onProfile={() => openModal('profile')}
        onSecurity={() => openModal('security')}
        onPrivacy={() => openModal('privacy')}
        onLogout={logout}
      />

      <main id="main-content">
        <Hero />
        <About />
        <Themes />

        <Suspense fallback={<div className="section-padding flex justify-center"><LoadingSpinner size="lg" /></div>}>
          <DemocracyGameHub />
        </Suspense>

        <Suspense fallback={<div className="section-padding flex justify-center"><LoadingSpinner /></div>}>
          <BridgeBuilding />
        </Suspense>

        <Suspense fallback={<div className="section-padding flex justify-center"><LoadingSpinner /></div>}>
          <BridgeBuilding100 />
        </Suspense>

        <Suspense fallback={<div className="section-padding flex justify-center"><LoadingSpinner /></div>}>
          <Forum />
        </Suspense>

        <Suspense fallback={<div className="section-padding flex justify-center"><LoadingSpinner /></div>}>
          <Join />
        </Suspense>

        <Suspense fallback={<div className="section-padding flex justify-center"><LoadingSpinner /></div>}>
          <Donate />
        </Suspense>

        <Suspense fallback={<div className="section-padding flex justify-center"><LoadingSpinner /></div>}>
          <Events />
        </Suspense>

        <Suspense fallback={<div className="section-padding flex justify-center"><LoadingSpinner /></div>}>
          <News />
        </Suspense>

        <Suspense fallback={<div className="section-padding flex justify-center"><LoadingSpinner /></div>}>
          <Contact />
        </Suspense>
      </main>

      {state.isAuthenticated && state.user?.role === 'admin' && (
        <Suspense fallback={<div className="section-padding flex justify-center"><LoadingSpinner /></div>}>
          <section id="admin-dashboard" className="bg-muted/30 border-t">
            <AdminDashboard />
          </section>
        </Suspense>
      )}

      <Footer />

      <ModalManager />
      <PWAInstaller />
      <CookieConsent />
      <BackToTop showAfter={400} />
      <ScrollProgress />
      <ServiceWorkerRegistration />
      <ToastProvider />
    </div>
  );
}

export default function App() {
  return (
    <ErrorBoundary>
      <AppStateProvider>
        <AppContent />
      </AppStateProvider>
    </ErrorBoundary>
  );
}
