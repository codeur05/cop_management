import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { LogIn, UserPlus, Mail, Lock, User, ShieldCheck } from 'lucide-react';
import './AuthPage.css';

const AuthPage = () => {
  const [isLogin, setIsLogin] = useState(true);
  const [formData, setFormData] = useState({
    firstName: '',
    lastName: '',
    email: '',
    password: '',
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  
  const { login, register } = useAuth();
  const navigate = useNavigate();

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    
    try {
      if (isLogin) {
        await login(formData.email, formData.password);
        navigate('/');
      } else {
        const data = await register(formData);
        navigate(`/verify-otp?email=${encodeURIComponent(data.email)}`);
      }
    } catch (err) {
      setError(err.response?.data?.message || 'Une erreur est survenue');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-container">
      <div className="auth-brand">
        <div className="brand-logo">
          <ShieldCheck size={48} color="white" />
        </div>
        <h1>Digital Cooperative Management</h1>
        <p>Gérez vos contributions et restez connecté à votre coopérative en toute sécurité.</p>
      </div>
      
      <div className="auth-card-wrapper">
        <div className={`auth-card premium-card animate-fade-in`}>
          <div className="auth-tabs">
            <button 
              className={isLogin ? 'active' : ''} 
              onClick={() => setIsLogin(true)}
            >
              Connexion
            </button>
            <button 
              className={!isLogin ? 'active' : ''} 
              onClick={() => setIsLogin(false)}
            >
              Inscription
            </button>
          </div>

          <form onSubmit={handleSubmit} className="auth-form">
            {!isLogin && (
              <div className="form-row">
                <div className="form-group">
                  <label>Prénom</label>
                  <div className="input-with-icon">
                    <User size={18} />
                    <input 
                      type="text" 
                      name="firstName" 
                      placeholder="Prénom" 
                      required 
                      value={formData.firstName}
                      onChange={handleChange}
                    />
                  </div>
                </div>
                <div className="form-group">
                  <label>Nom</label>
                  <div className="input-with-icon">
                    <User size={18} />
                    <input 
                      type="text" 
                      name="lastName" 
                      placeholder="Nom" 
                      required 
                      value={formData.lastName}
                      onChange={handleChange}
                    />
                  </div>
                </div>
              </div>
            )}
            
            <div className="form-group">
              <label>Email</label>
              <div className="input-with-icon">
                <Mail size={18} />
                <input 
                  type="email" 
                  name="email" 
                  placeholder="votre@email.com" 
                  required 
                  value={formData.email}
                  onChange={handleChange}
                />
              </div>
            </div>

            <div className="form-group">
              <label>Mot de passe</label>
              <div className="input-with-icon">
                <Lock size={18} />
                <input 
                  type="password" 
                  name="password" 
                  placeholder="••••••••" 
                  required 
                  value={formData.password}
                  onChange={handleChange}
                />
              </div>
            </div>

            {error && <div className="auth-error">{error}</div>}

            <button type="submit" className="auth-btn" disabled={loading}>
              {loading ? 'Chargement...' : (
                <>
                  {isLogin ? <LogIn size={20} /> : <UserPlus size={20} />}
                  <span>{isLogin ? 'Se connecter' : 'Créer un compte'}</span>
                </>
              )}
            </button>
          </form>

          <p className="auth-footer">
            {isLogin ? "Vous n'avez pas de compte ?" : "Déjà membre ?"}
            <span onClick={() => setIsLogin(!isLogin)}>
              {isLogin ? " S'inscrire" : " Se connecter"}
            </span>
          </p>
        </div>
      </div>
    </div>
  );
};

export default AuthPage;
