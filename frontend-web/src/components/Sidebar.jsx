import React from 'react';
import { NavLink } from 'react-router-dom';
import { 
  LayoutDashboard, 
  Users, 
  HandCoins, 
  UserCircle, 
  LogOut, 
  ShieldCheck,
  TrendingUp,
  Wallet
} from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import './Sidebar.css';

const Sidebar = () => {
  const { user, logout } = useAuth();
  
  const menuItems = [
    { name: 'Tableau de Bord', path: '/', icon: LayoutDashboard, roles: ['Admin', 'Tresorier', 'Membre'], portal: 'Global' },
    { name: 'Membres & Rôles', path: '/members', icon: Users, roles: ['Admin'], portal: 'Admin' },
    { name: 'Gestion Financière', path: '/contributions', icon: HandCoins, roles: ['Admin', 'Tresorier'], portal: 'Finance' },
    { name: 'Virements', path: '/transfers', icon: Wallet, roles: ['Admin', 'Tresorier'], portal: 'Finance' },
    { name: 'Rapports', path: '/reports', icon: TrendingUp, roles: ['Admin', 'Tresorier'], portal: 'Finance' },
    { name: 'Mon Espace', path: '/my-contributions', icon: TrendingUp, roles: ['Membre'], portal: 'Member' },
  ];

  const filteredItems = menuItems.filter(item => item.roles.includes(user?.role));

  return (
    <div className="sidebar shadow-lg">
      <div className="sidebar-header">
        <div className="logo-container">
          <ShieldCheck size={32} className="logo-icon" />
          <div className="logo-text">
            <span>Digital</span>
            <small>Cooperative</small>
          </div>
        </div>
      </div>
      
      <nav className="sidebar-nav">
        {filteredItems.map((item) => (
          <NavLink 
            key={item.path} 
            to={item.path} 
            className={({ isActive }) => `nav-link ${isActive ? 'active' : ''}`}
          >
            <item.icon size={20} />
            <span>{item.name}</span>
          </NavLink>
        ))}
      </nav>

      <div className="sidebar-footer">
        <div className="user-info">
          <UserCircle size={32} />
          <div className="user-details">
            <p className="user-name">{user?.firstName} {user?.lastName}</p>
            <span className="user-role">{user?.role}</span>
          </div>
        </div>
        <button onClick={logout} className="logout-btn">
          <LogOut size={18} />
          <span>Déconnexion</span>
        </button>
      </div>
    </div>
  );
};

export default Sidebar;
