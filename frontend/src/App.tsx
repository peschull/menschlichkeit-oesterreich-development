import React, { Suspense } from 'react';
import { BrowserRouter, Route, Routes } from 'react-router-dom';
import { AuthProvider } from './auth/AuthContext';
import { Navigation } from './components/ui/Navigation';
import { ProtectedRoute } from './routes/ProtectedRoute';

const Home = React.lazy(() => import('./pages/Home'));
const Login = React.lazy(() => import('./pages/Login'));
const MemberArea = React.lazy(() => import('./pages/MemberArea'));

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Navigation />
        <main id="main">
          <Suspense fallback={<div className="p-4">Lade …</div>}>
            <Routes>
              <Route path="/" element={<Home />} />
              <Route path="/login" element={<Login />} />
              <Route
                path="/member"
                element={
                  <ProtectedRoute>
                    <MemberArea />
                  </ProtectedRoute>
                }
              />
            </Routes>
          </Suspense>
        </main>
      </AuthProvider>
    </BrowserRouter>
  );
}
