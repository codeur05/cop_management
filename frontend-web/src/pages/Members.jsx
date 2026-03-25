import React, { useState, useEffect } from 'react';
import { Search, UserCog, MoreVertical, Edit2, Trash2 } from 'lucide-react';
import api from '../services/api';
import Layout from '../components/Layout';
import './Members.css';

const Members = () => {
  const [members, setMembers] = useState([]);
  const [searchTerm, setSearchTerm] = useState('');
  const [roleFilter, setRoleFilter] = useState('All');
  const [loading, setLoading] = useState(true);

  const fetchMembers = async () => {
    try {
      const { data } = await api.get('/members');
      setMembers(data);
      setLoading(false);
    } catch (err) {
      console.error(err);
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchMembers();
  }, []);

  const handleRoleChange = async (id, newRole) => {
    try {
      await api.put(`/members/${id}/role`, { role: newRole });
      fetchMembers();
    } catch {
      alert('Erreur lors du changement de rôle');
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer cet utilisateur ?')) {
      try {
        await api.delete(`/members/${id}`);
        fetchMembers();
      } catch {
        alert('Erreur lors de la suppression');
      }
    }
  };

  const filteredMembers = members.filter(m => {
    const matchesSearch = `${m.firstName} ${m.lastName}`.toLowerCase().includes(searchTerm.toLowerCase()) ||
      m.email.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesRole = roleFilter === 'All' || m.role === roleFilter;
    return matchesSearch && matchesRole;
  });

  const stats = {
    total: members.length,
    admins: members.filter(m => m.role === 'Admin').length,
    treasurers: members.filter(m => m.role === 'Tresorier').length,
    members: members.filter(m => m.role === 'Membre').length
  };

  return (
    <Layout title="Gestion des Membres">
      <div className="members-page">
        <div className="members-summary-grid">
          <div className="summary-card">
            <span>Total</span>
            <strong>{stats.total}</strong>
          </div>
          <div className="summary-card admin">
            <span>Admins</span>
            <strong>{stats.admins}</strong>
          </div>
          <div className="summary-card treasurer">
            <span>Trésoriers</span>
            <strong>{stats.treasurers}</strong>
          </div>
          <div className="summary-card member">
            <span>Membres</span>
            <strong>{stats.members}</strong>
          </div>
        </div>

        <div className="members-header premium-card">
          <div className="search-bar">
            <Search size={20} />
            <input 
              type="text" 
              placeholder="Rechercher un membre par nom ou email..." 
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
          <div className="filter-group">
            <select value={roleFilter} onChange={(e) => setRoleFilter(e.target.value)}>
              <option value="All">Tous les rôles</option>
              <option value="Admin">Admin</option>
              <option value="Tresorier">Trésorier</option>
              <option value="Membre">Membre</option>
            </select>
            <button className="primary-btn">Inviter un membre</button>
          </div>
        </div>

        <div className="members-list premium-card">
          <table className="main-table">
            <thead>
              <tr>
                <th>Membre</th>
                <th>Email</th>
                <th>Rôle</th>
                <th>Statut</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {filteredMembers.map(m => (
                <tr key={m._id}>
                  <td>
                    <div className="member-info">
                      <div className="avatar large">{m.firstName[0]}</div>
                      <div>
                        <p className="name">{m.firstName} {m.lastName}</p>
                        <p className="id">ID: {m._id.substring(18)}</p>
                      </div>
                    </div>
                  </td>
                  <td>{m.email}</td>
                  <td>
                    <select 
                      className="role-select"
                      value={m.role}
                      onChange={(e) => handleRoleChange(m._id, e.target.value)}
                    >
                      <option value="Membre">Membre</option>
                      <option value="Tresorier">Trésorier</option>
                      <option value="Admin">Admin</option>
                    </select>
                  </td>
                  <td><span className="badge success">Actif</span></td>
                  <td>
                    <div className="action-btns">
                      <button className="icon-btn danger" onClick={() => handleDelete(m._id)}>
                        <Trash2 size={18} />
                      </button>
                      <button className="icon-btn"><MoreVertical size={18} /></button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          {filteredMembers.length === 0 && !loading && (
            <div className="empty-state">Aucun membre trouvé.</div>
          )}
        </div>
      </div>
    </Layout>
  );
};

export default Members;
