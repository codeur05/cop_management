import React, { useState, useEffect } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import api from '../services/api';
import { Mail, ShieldCheck, ArrowLeft, RefreshCw, CheckCircle2 } from 'lucide-react';
import './AuthPage.css'; // Reuse common styles

const VerifyOtp = () => {
  const [otp, setOtp] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [loading, setLoading] = useState(false);
  const [resending, setResending] = useState(false);
  
  const navigate = useNavigate();
  const location = useLocation();
  const email = new URLSearchParams(location.search).get('email');

  useEffect(() => {
    if (!email) {
      navigate('/login');
    }
  }, [email, navigate]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (otp.length !== 6) {
      setError('Le code doit contenir 6 chiffres');
      return;
    }

    setError('');
    setLoading(true);
    try {
      await api.post('/auth/verify-otp', { email, otp });
      setSuccess('Email vérifié avec succès ! Redirection vers la connexion...');
      setTimeout(() => navigate('/login'), 2000);
    } catch (err) {
      setError(err.response?.data?.message || 'Code invalide ou expiré');
    } finally {
      setLoading(false);
    }
  };

  const handleResend = async () => {
    setError('');
    setResending(true);
    try {
      await api.post('/auth/resend-otp', { email });
      setSuccess('Un nouveau code a été envoyé à votre email.');
    } catch (err) {
      setError(err.response?.data?.message || 'Erreur lors du renvoi du code');
    } finally {
      setResending(false);
    }
  };

  return (
    <div className="auth-container">
      <div className="auth-brand">
        <div className="brand-logo">
          <ShieldCheck size={48} color="white" />
        </div>
        <h1>Vérification de compte</h1>
        <p>Un code de vérification à 6 chiffres a été envoyé à <strong>{email}</strong>.</p>
      </div>

      <div className="auth-card-wrapper">
        <div className="auth-card premium-card animate-fade-in">
          <div className="otp-header">
            <Mail size={32} className="otp-icon" />
            <h2>Saisir le code</h2>
          </div>

          <form onSubmit={handleSubmit} className="auth-form">
            <div className="form-group">
              <label>Code OTP</label>
              <div className="input-with-icon">
                <ShieldCheck size={18} />
                <input 
                  type="text" 
                  maxLength="6"
                  placeholder="000000"
                  required 
                  value={otp}
                  onChange={(e) => setOtp(e.target.value.replace(/\D/g, ''))}
                />
              </div>
            </div>

            {error && <div className="auth-error">{error}</div>}
            {success && (
              <div className="auth-success">
                <CheckCircle2 size={18} />
                <span>{success}</span>
              </div>
            )}

            <button type="submit" className="auth-btn" disabled={loading || success}>
              {loading ? 'Vérification...' : 'Vérifier le compte'}
            </button>
          </form>

          <div className="otp-actions">
            <button 
              className="text-btn" 
              onClick={handleResend} 
              disabled={resending || success}
            >
              {resending ? <RefreshCw className="animate-spin" size={16} /> : <RefreshCw size={16} />}
              <span>Renvoyer le code</span>
            </button>
            <button className="text-btn back-btn" onClick={() => navigate('/login')}>
              <ArrowLeft size={16} />
              <span>Retour à la connexion</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default VerifyOtp;
