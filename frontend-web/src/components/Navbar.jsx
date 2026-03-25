import React from 'react';
import { useAuth } from '../context/AuthContext';
import './Navbar.css';

const Navbar = ({ title }) => {
  const { user } = useAuth();

  return (
    <header className="navbar glass shadow-sm">
      <div className="navbar-left">
        <h1 className="page-title">{title}</h1>
      </div>
      <div className="navbar-right">
        <div className="user-badge">
          <span>{user?.firstName?.[0]}{user?.lastName?.[0]}</span>
        </div>
      </div>
    </header>
  );
};

export default Navbar;
