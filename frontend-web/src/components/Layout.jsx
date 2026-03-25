import React from 'react';
import Navbar from './Navbar';
import Sidebar from './Sidebar';
import './Layout.css';

const Layout = ({ children, title }) => {
  return (
    <div className="layout">
      <Sidebar />
      <div className="layout-main">
        <Navbar title={title} />
        <main className="layout-content animate-fade-in">
          {children}
        </main>
      </div>
    </div>
  );
};

export default Layout;
