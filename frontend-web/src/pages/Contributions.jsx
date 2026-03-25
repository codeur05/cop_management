import React, { useState, useEffect } from 'react';
import { Plus, Filter, Download, Calendar, Edit2, Trash2, User } from 'lucide-react';
import api from '../services/api';
import Layout from '../components/Layout';
import './Contributions.css';

const Contributions = () => {
  const [contributions, setContributions] = useState([]);
  const [members, setMembers] = useState([]);
  const [showModal, setShowModal] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [editId, setEditId] = useState(null);
  const [formData, setFormData] = useState({ amount: '', type: 'Cotisation', member: '', status: 'Payé' });
  
  const fetchContributions = async () => {
    try {
      const { data } = await api.get('/contributions');
      setContributions(data);
    } catch (err) {
      console.error(err);
    }
  };

  const fetchMembers = async () => {
    try {
      const { data } = await api.get('/members');
      setMembers(data);
    } catch (err) {
      console.error(err);
    }
  };

  useEffect(() => {
    fetchContributions();
    fetchMembers();
  }, []);

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (isEditing) {
        await api.put(`/contributions/${editId}`, formData);
      } else {
        await api.post('/contributions', formData);
      }
      closeModal();
      fetchContributions();
    } catch {
      alert(`Erreur lors de ${isEditing ? 'la modification' : 'l\'ajout'}`);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Voulez-vous supprimer cette contribution ?')) {
      try {
        await api.delete(`/contributions/${id}`);
        fetchContributions();
    } catch {
        alert('Erreur lors de la suppression');
      }
    }
  };

  const openEditModal = (contribution) => {
    setFormData({
      amount: contribution.amount,
      type: contribution.type,
      member: contribution.member?._id,
      status: contribution.status
    });
    setEditId(contribution._id);
    setIsEditing(true);
    setShowModal(true);
  };

  const closeModal = () => {
    setShowModal(false);
    setIsEditing(false);
    setEditId(null);
    setFormData({ amount: '', type: 'Cotisation', member: '', status: 'Payé' });
  };

  return (
    <Layout title="Gestion des Contributions">
      <div className="contributions-page">
        <div className="page-header premium-card shadow-sm">
          <div className="header-info">
            <h2>Journal des Transactions</h2>
            <p>Visualisez et gérez toutes les contributions de la coopérative.</p>
          </div>
          <div className="header-actions">
            <button className="secondary-btn"><Download size={18} /> Exporter</button>
            <button className="primary-btn" onClick={() => setShowModal(true)}>
              <Plus size={18} /> Nouvelle Contribution
            </button>
          </div>
        </div>

        <div className="contributions-list premium-card">
          <table className="main-table">
            <thead>
              <tr>
                <th>Membre</th>
                <th>Montant</th>
                <th>Type</th>
                <th>Date</th>
                <th>Statut</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {contributions.map(c => (
                <tr key={c._id}>
                  <td>
                    <div className="member-cell">
                      <span>{c.member?.firstName} {c.member?.lastName}</span>
                    </div>
                  </td>
                  <td className="amount">{c.amount} FCFA</td>
                  <td>
                    <span className={`type-tag ${c.type.toLowerCase()}`}>
                      {c.type}
                    </span>
                  </td>
                  <td>
                    <div className="date-cell">
                      <Calendar size={14} />
                      {new Date(c.date).toLocaleDateString()}
                    </div>
                  </td>
                  <td>
                    <span className={`badge ${c.status === 'Payé' ? 'success' : 'danger'}`}>
                      {c.status}
                    </span>
                  </td>
                  <td>
                    <div className="action-btns">
                      <button className="icon-btn edit" onClick={() => openEditModal(c)}>
                        <Edit2 size={16} />
                      </button>
                      <button className="icon-btn delete" onClick={() => handleDelete(c._id)}>
                        <Trash2 size={16} />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {showModal && (
          <div className="modal-overlay">
            <div className="modal-content animate-fade-in premium-card">
              <h3>{isEditing ? 'Modifier la Contribution' : 'Nouvelle Contribution'}</h3>
              <form onSubmit={handleSubmit}>
                <div className="form-group">
                  <label>Montant (FCFA)</label>
                  <input 
                    type="number" 
                    required 
                    value={formData.amount}
                    onChange={(e) => setFormData({...formData, amount: e.target.value})}
                  />
                </div>
                <div className="form-group">
                  <label>Membre</label>
                  <select 
                    required
                    value={formData.member}
                    onChange={(e) => setFormData({...formData, member: e.target.value})}
                  >
                    <option value="">Sélectionner un membre</option>
                    {members.map(m => (
                      <option key={m._id} value={m._id}>{m.firstName} {m.lastName}</option>
                    ))}
                  </select>
                </div>
                <div className="form-group">
                  <label>Type</label>
                  <select 
                    value={formData.type}
                    onChange={(e) => setFormData({...formData, type: e.target.value})}
                  >
                    <option value="Cotisation">Cotisation</option>
                    <option value="Don">Don</option>
                  </select>
                </div>
                <div className="form-group">
                  <label>Statut</label>
                  <select 
                    value={formData.status}
                    onChange={(e) => setFormData({...formData, status: e.target.value})}
                  >
                    <option value="Payé">Payé</option>
                    <option value="En retard">En retard</option>
                  </select>
                </div>
                <div className="modal-actions">
                  <button type="button" onClick={closeModal} className="cancel-btn">Annuler</button>
                  <button type="submit" className="primary-btn">
                    {isEditing ? 'Mettre à jour' : 'Enregistrer'}
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}
      </div>
    </Layout>
  );
};

export default Contributions;
