import React, { useState, useEffect } from 'react';
import { CheckCircle, XCircle, Clock, Search } from 'lucide-react';
import api from '../services/api';
import Layout from '../components/Layout';
import './Transfers.css';

const Transfers = () => {
  const [transfers, setTransfers] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchTransfers = async () => {
    try {
      const { data } = await api.get('/transfers');
      setTransfers(data);
      setLoading(false);
    } catch (err) {
      console.error(err);
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchTransfers();
  }, []);

  const handleStatusUpdate = async (id, status) => {
    try {
      await api.put(`/transfers/${id}/status`, { status });
      fetchTransfers();
    } catch {
      alert('Erreur lors de la mise à jour du statut');
    }
  };

  return (
    <Layout title="Gestion des Virements">
      <div className="transfers-page">
        <div className="transfers-list premium-card">
          <table className="main-table">
            <thead>
              <tr>
                <th>Membre</th>
                <th>Montant</th>
                <th>Date</th>
                <th>Statut</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {transfers.map(t => (
                <tr key={t._id}>
                  <td>
                    <div className="member-info">
                      <div className="avatar">{t.member?.firstName?.[0] || '?'}</div>
                      <div>
                        <p className="name">{t.member ? `${t.member.firstName} ${t.member.lastName}` : 'Membre supprimé'}</p>
                        <p className="email">{t.member?.email || 'N/A'}</p>
                      </div>
                    </div>
                  </td>
                  <td className="amount">{t.amount.toLocaleString()} FCFA</td>
                  <td>{new Date(t.date).toLocaleDateString()}</td>
                  <td>
                    <span className={`badge ${
                      t.status === 'Approuvé' ? 'success' : 
                      t.status === 'Rejeté' ? 'danger' : 'warning'
                    }`}>
                      {t.status}
                    </span>
                  </td>
                  <td>
                    {t.status === 'En attente' && (
                      <div className="action-btns">
                        <button className="icon-btn success" onClick={() => handleStatusUpdate(t._id, 'Approuvé')}>
                          <CheckCircle size={18} />
                        </button>
                        <button className="icon-btn danger" onClick={() => handleStatusUpdate(t._id, 'Rejeté')}>
                          <XCircle size={18} />
                        </button>
                      </div>
                    )}
                  </td>
                </tr>
              ))}
              {transfers.length === 0 && !loading && (
                <tr>
                  <td colSpan="5" className="empty-state">Aucune demande de virement trouvée.</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </Layout>
  );
};

export default Transfers;
