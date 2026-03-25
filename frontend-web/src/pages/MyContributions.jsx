import React, { useState, useEffect } from 'react';
import { CreditCard, History, Clock, FileText } from 'lucide-react';
import api from '../services/api';
import Layout from '../components/Layout';

const MyContributions = () => {
  const [contributions, setContributions] = useState([]);
  const [transfers, setTransfers] = useState([]);

  const fetchMyData = async () => {
    try {
      const { data: contribData } = await api.get('/my-contributions');
      setContributions(contribData);
      
      const { data: transData } = await api.get('/transfers/my-transfers');
      setTransfers(transData);
    } catch (err) {
      console.error(err);
    }
  };

  useEffect(() => {
    fetchMyData();
  }, []);

  const totalPaid = contributions.reduce((acc, curr) => acc + curr.amount, 0);
  const totalDebt = transfers
    .filter(t => t.status === 'Approuvé')
    .reduce((acc, curr) => acc + curr.amount, 0);

  return (
    <Layout title="Mes Contributions">
      <div className="my-contributions">
        <div className="stats-grid">
          <div className="stat-card premium-card blue">
            <div className="stat-icon"><History size={24} /></div>
            <div className="stat-info">
              <h4>Total Cotisé</h4>
              <p className="stat-value">{totalPaid.toLocaleString()} FCFA</p>
            </div>
          </div>
          <div className="stat-card premium-card orange">
            <div className="stat-icon"><Clock size={24} /></div>
            <div className="stat-info">
              <h4>Dette Totale</h4>
              <p className="stat-value">{totalDebt.toLocaleString()} FCFA</p>
              <span className="stat-label">Virements approuvés</span>
            </div>
          </div>
        </div>

        <div className="history-section premium-card" style={{ marginTop: '2rem' }}>
          <div className="section-header">
            <h3>Historique de mes virements</h3>
          </div>
          
          <table className="main-table">
            <thead>
              <tr>
                <th>Date</th>
                <th>Montant</th>
                <th>Statut</th>
              </tr>
            </thead>
            <tbody>
              {transfers.map(t => (
                <tr key={t._id}>
                  <td>{new Date(t.date).toLocaleDateString()}</td>
                  <td className="amount">{t.amount} FCFA</td>
                  <td>
                    <span className={`badge ${
                      t.status === 'Approuvé' ? 'success' : 
                      t.status === 'Rejeté' ? 'danger' : 'warning'
                    }`}>
                      {t.status}
                    </span>
                  </td>
                </tr>
              ))}
              {transfers.length === 0 && (
                <tr>
                  <td colSpan="3" className="empty-state">
                    Aucun virement enregistré.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </Layout>
  );
};

export default MyContributions;
