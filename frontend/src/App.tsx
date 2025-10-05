import React, { Suspense, lazy } from 'react';
import { BrowserRouter, Route, Routes } from 'react-router-dom';
import AITestPage from './pages/AITestPage';
import PrivacySettings from './pages/PrivacySettings';
import ProtectedRoute from './components/ProtectedRoute';
import MemberArea from './pages/MemberArea';
import NavBar from './components/NavBar';
import Login from './pages/Login';

// Fallback für fehlende Components
const Home = React.lazy(() =>
  import('./pages/Home').catch(() => ({ default: () => <AITestPage /> }))
);

// Figma‑integrierte Feature‑Komponenten (lazy geladen)
const DemocracyGameHub = lazy(() => import('@/components/DemocracyGameHub'));
const BridgeBuilding = lazy(() => import('@/components/BridgeBuilding'));
const BridgeBuilding100 = lazy(() => import('@/components/BridgeBuilding100'));
const Forum = lazy(() => import('@/components/Forum'));
const Events = lazy(() => import('@/components/Events'));
const News = lazy(() => import('@/components/News'));
const Join = lazy(() => import('@/components/Join'));
const Donate = lazy(() => import('@/components/Donate'));
const Contact = lazy(() => import('@/components/Contact'));
const AdminDashboard = lazy(() => import('@/components/AdminDashboard'));

export default function App() {
  return (
    <BrowserRouter>
      <NavBar />
      <main id="main">
        <Suspense
          fallback={
            <div className="flex items-center justify-center min-h-screen">
              <div className="text-center">
                <div className="w-8 h-8 border-4 border-primary-500 border-t-transparent rounded-full animate-spin mx-auto mb-4"></div>
                <p className="text-muted">🤖 KI-System wird geladen...</p>
              </div>
            </div>
          }
        >
          <Routes>
            <Route path="/" element={<AITestPage />} />
            <Route path="/ai-demo" element={<AITestPage />} />
            <Route path="/home" element={<Home />} />
            <Route path="/Login" element={<Login />} />
            <Route path="/account/privacy" element={<ProtectedRoute><PrivacySettings /></ProtectedRoute>} />
            <Route path="/member" element={<ProtectedRoute><MemberArea /></ProtectedRoute>} />
            {/* Neue Hauptbereiche aus Figma‑Integration */}
            <Route path="/games" element={<DemocracyGameHub />} />
            <Route path="/games/bridge" element={<BridgeBuilding />} />
            <Route path="/games/bridge-100" element={<BridgeBuilding100 />} />
            <Route path="/forum" element={<Forum />} />
            <Route path="/events" element={<Events />} />
            <Route path="/news" element={<News />} />
            <Route path="/join" element={<Join />} />
            <Route path="/donate" element={<Donate />} />
            <Route path="/contact" element={<Contact />} />
            <Route path="/admin" element={<ProtectedRoute><AdminDashboard /></ProtectedRoute>} />
          </Routes>
        </Suspense>
      </main>
    </BrowserRouter>
  );
}
