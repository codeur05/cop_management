import React, { useState, useEffect } from 'react';
import { 
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, Legend
} from 'recharts';
import { Download, FileText, PieChart as PieIcon, BarChart3 } from 'lucide-react';
import api from '../services/api';
import Layout from '../components/Layout';
import './Reports.css';

const Reports = () => {
  const [stats, setStats] = useState({ types: [], status: [] });
  const [loading, setLoading] = useState(true);

  const fetchStats = async () => {
    try {
      const { data } = await api.get('/contributions/stats/summary');
      setStats(data);
      setLoading(false);
    } catch (err) {
      console.error(err);
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchStats();
  }, []);

  const COLORS = ['#2563eb', '#7c3aed', '#f59e0b', '#ef4444', '#10b981'];

  if (loading) return <Layout title="Rapports Financiers"><div className="loading">Chargement...</div></Layout>;

  return (
    <Layout title="Rapports Financiers">
      <div className="reports-page">
        <div className="reports-header premium-card">
          <div className="header-content">
            <FileText size={32} className="header-icon" />
            <div>
              <h2>Synthèse Financière</h2>
              <p>Rapport détaillé des contributions et ressources de la coopérative.</p>
            </div>
          </div>
          <button className="primary-btn" onClick={() => window.print()}>
            <Download size={18} /> Télécharger PDF
          </button>
        </div>

        <div className="reports-grid">
          <div className="report-card premium-card">
            <h3><BarChart3 size={20} /> Répartition par Type</h3>
            <div className="chart-container">
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={stats?.types || []}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} />
                  <XAxis dataKey="_id" />
                  <YAxis />
                  <Tooltip />
                  <Bar dataKey="total" fill="#2563eb" radius={[4, 4, 0, 0]} label={{ position: 'top' }} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>

          <div className="report-card premium-card">
            <h3><PieIcon size={20} /> Statut des Paiements</h3>
            <div className="chart-container">
              <ResponsiveContainer width="100%" height={300}>
                <PieChart>
                  <Pie
                    data={stats?.status || []}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    outerRadius={100}
                    fill="#8884d8"
                    dataKey="count"
                    label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                  >
                    {(stats?.status || []).map((entry, index) => (
                      <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                  <Legend />
                </PieChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>

        <div className="summary-table premium-card">
          <h3>Tableau Récapitulatif</h3>
          <table className="main-table">
            <thead>
              <tr>
                <th>Catégorie</th>
                <th>Nombre de Transactions</th>
                <th>Montant Total</th>
              </tr>
            </thead>
            <tbody>
              {stats.types.map(t => (
                <tr key={t._id}>
                  <td>{t._id}</td>
                  <td>{t.count}</td>
                  <td className="amount">{(t.total || 0).toLocaleString()} FCFA</td>
                </tr>
              ))}
              <tr className="grand-total">
                <td><strong>TOTAL GÉNÉRAL</strong></td>
                <td><strong>{stats.types.reduce((acc, curr) => acc + (curr.count || 0), 0)}</strong></td>
                <td className="amount"><strong>{stats.types.reduce((acc, curr) => acc + (curr.total || 0), 0).toLocaleString()} FCFA</strong></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </Layout>
  );
};

export default Reports;
