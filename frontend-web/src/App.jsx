import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './context/AuthContext';
import AuthPage from './pages/AuthPage';
import VerifyOtp from './pages/VerifyOtp';
import Dashboard from './pages/Dashboard';
import Members from './pages/Members';
import Contributions from './pages/Contributions';
import MyContributions from './pages/MyContributions';
import Transfers from './pages/Transfers';
import Reports from './pages/Reports';
import Layout from './components/Layout';
import './index.css';

const PrivateRoute = ({ children, roles }) => {
  const { user } = useAuth();
  if (!user) return <Navigate to="/auth" />;
  if (roles && !roles.includes(user.role)) return <Navigate to="/" />;
  return children;
};

const App = () => {
  return (
    <Router>
      <AuthProvider>
        <Routes>
          <Route path="/auth" element={<AuthPage />} />
          <Route path="/verify-otp" element={<VerifyOtp />} />
          
          <Route path="/" element={
            <PrivateRoute>
              <Layout title="Tableau de Bord">
                <Dashboard />
              </Layout>
            </PrivateRoute>
          } />

          <Route path="/members" element={
            <PrivateRoute roles={['Admin']}>
              <Members />
            </PrivateRoute>
          } />

          <Route path="/contributions" element={
            <PrivateRoute roles={['Admin', 'Tresorier']}>
              <Contributions />
            </PrivateRoute>
          } />

          <Route path="/transfers" element={
            <PrivateRoute roles={['Admin', 'Tresorier']}>
              <Transfers />
            </PrivateRoute>
          } />

          <Route path="/reports" element={
            <PrivateRoute roles={['Admin', 'Tresorier']}>
              <Reports />
            </PrivateRoute>
          } />

          <Route path="/my-contributions" element={
            <PrivateRoute roles={['Membre']}>
              <MyContributions />
            </PrivateRoute>
          } />

          <Route path="*" element={<Navigate to="/" />} />
        </Routes>
      </AuthProvider>
    </Router>
  );
};

export default App;
