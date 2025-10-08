// Frontend Performance Optimization - Code Splitting Implementation
// Menschlichkeit Österreich - Austrian NGO Platform
// Stand: 7. Oktober 2025

import { lazy, Suspense } from 'react';
import { Routes, Route } from 'react-router-dom';
import ErrorBoundary from './components/ErrorBoundary';
import LoadingSpinner from './components/LoadingSpinner';

// Lazy Load Components - Code Splitting
const HomePage = lazy(() => import('./pages/HomePage'));
const DonationForm = lazy(() => import('./pages/DonationForm'));
const MembershipPage = lazy(() => import('./pages/MembershipPage'));
const AboutPage = lazy(() => import('./pages/AboutPage'));
const ContactPage = lazy(() => import('./pages/ContactPage'));
const GamePlatform = lazy(() => import('./pages/GamePlatform'));

// Heavy Components - Split into separate bundles
const CRMDashboard = lazy(() => import('./pages/admin/CRMDashboard'));
const AnalyticsDashboard = lazy(() => import('./pages/admin/AnalyticsDashboard'));
const UserManagement = lazy(() => import('./pages/admin/UserManagement'));

// Chart Components - Only load when needed
const ChartComponents = lazy(() => import('./components/charts/ChartBundle'));
const ReportGenerator = lazy(() => import('./components/reports/ReportGenerator'));

function App() {
  return (
    <ErrorBoundary>
      <Suspense fallback={<LoadingSpinner message="Lade Inhalte..." />}>
        <Routes>
          {/* Public Routes */}
          <Route path="/" element={<HomePage />} />
          <Route path="/spenden" element={<DonationForm />} />
          <Route path="/mitglied-werden" element={<MembershipPage />} />
          <Route path="/über-uns" element={<AboutPage />} />
          <Route path="/kontakt" element={<ContactPage />} />
          <Route path="/spiele/*" element={<GamePlatform />} />
          
          {/* Admin Routes - Heavy Components */}
          <Route path="/admin/crm" element={<CRMDashboard />} />
          <Route path="/admin/analytics" element={<AnalyticsDashboard />} />
          <Route path="/admin/users" element={<UserManagement />} />
          
          {/* Feature Routes - Load on Demand */}
          <Route path="/reports/*" element={<ReportGenerator />} />
          <Route path="/charts/*" element={<ChartComponents />} />
        </Routes>
      </Suspense>
    </ErrorBoundary>
  );
}

export default App;