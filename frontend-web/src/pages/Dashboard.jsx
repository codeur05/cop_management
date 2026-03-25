import React, { useState, useEffect } from 'react';
import { 
  Users, 
  Wallet, 
  HandCoins, 
  AlertCircle, 
  ChevronUp, 
  ChevronDown,
  ArrowRight,
  History
} from 'lucide-react';
import { 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell
} from 'recharts';
import api from '../services/api';
import { useAuth } from '../context/AuthContext';
import './Dashboard.css';

const TransferModal = ({ isOpen, onClose, onSubmit }) => {
  const [amount, setAmount] = useState('');
  
  if (!isOpen) return null;
  
  return (
    <div className="modal-overlay">
      <div className="premium-card modal-content">
        <h3>Demander un virement</h3>
        <p>Entrez le montant que vous souhaitez retirer.</p>
        <div className="input-field">
          <input 
            type="number" 
            placeholder="Montant (FCFA)" 
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
          />
        </div>
        <div className="modal-actions">
          <button className="secondary-btn" onClick={onClose}>Annuler</button>
          <button className="primary-btn" onClick={() => onSubmit(amount)}>Envoyer</button>
        </div>
      </div>
    </div>
  );
};

const Dashboard = () => {
  const { user } = useAuth();
  const [stats, setStats] = useState({
    totalContributions: 0,
    monthlyContributions: 0,
    latePayments: 0,
    treasurerCount: 0,
    totalDebt: 0
  });
  const [chartData, setChartData] = useState([]);
  const [members, setMembers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [config, setConfig] = useState(null);
  const [editConfig, setEditConfig] = useState({ purpose: '', amount: '', dueDate: '' });
  const [isSavingConfig, setIsSavingConfig] = useState(false);

  const fetchData = async () => {
    try {
      const { data: configData } = await api.get('/config');
      setConfig(configData);
      setEditConfig({
        purpose: configData?.purpose || '',
        amount: configData?.amount || '',
        dueDate: configData?.dueDate ? configData.dueDate.substring(0, 10) : ''
      });

      const isAdminOrTresorier = ['Admin', 'Tresorier'].includes(user?.role);
      
      if (isAdminOrTresorier) {
        const { data: membersData } = await api.get('/members');
        const { data: contribData } = await api.get('/contributions');
        
        setMembers(membersData.slice(0, 5));
        
        const total = contribData.reduce((acc, curr) => acc + curr.amount, 0);
        const late = contribData.filter(c => c.status === 'En retard').length;
        
        setStats({
          totalMembers: membersData.length,
          totalContributions: total,
          monthlyContributions: total / 12,
          latePayments: late,
          treasurerCount: membersData.filter(m => m.role === 'Tresorier').length
        });
      } else {
        // For simple members
        const { data: myContribData } = await api.get('/my-contributions');
        const { data: myTransData } = await api.get('/transfers/my-transfers');
        
        const myContributions = myContribData.reduce((acc, curr) => acc + curr.amount, 0);
        const myDebt = myTransData
          .filter(t => t.status === 'Approuvé')
          .reduce((acc, curr) => acc + curr.amount, 0);

        setStats({
          totalContributions: myContributions,
          totalDebt: myDebt,
          monthlyContributions: myContribData.filter(c => {
            const date = new Date(c.date);
            return date.getMonth() === new Date().getMonth();
          }).length,
          latePayments: myContribData.filter(c => c.status === 'En retard').length
        });
      }

      // Chart data prep
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
      setChartData(months.map((m, i) => ({
        name: m,
        value: 100 + i * 50 + Math.random() * 100
      })));

      setLoading(false);
    } catch (err) {
      console.error(err);
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, [user]);

  const handleTransferRequest = async (amount) => {
    try {
      await api.post('/transfers', { amount });
      alert('Demande de virement envoyée avec succès');
      setIsModalOpen(false);
    } catch {
      alert('Erreur lors de la demande de virement');
    }
  };

  const handleConfigSave = async (e) => {
    e.preventDefault();
    setIsSavingConfig(true);
    try {
      const { data: updatedConfig } = await api.post('/config', editConfig);
      setConfig(updatedConfig);
      alert('Configuration mise à jour avec succès');
    } catch {
      alert('Erreur lors de la mise à jour de la configuration');
    } finally {
      setIsSavingConfig(false);
    }
  };

  const COLORS = ['#2563eb', '#7c3aed', '#f59e0b', '#ef4444'];

  const pieData = [
    { name: 'Cotisations', value: 400 },
    { name: 'Dons', value: 300 },
  ];

  if (loading) return <div className="loading">Chargement...</div>;

  return (
    <div className="dashboard-page">
      <div className="dashboard-header-context">
        <h2>Bienvenue, {user?.firstName}</h2>
        <p>Interface : <span className="role-tag">{user?.role}</span></p>
      </div>

      {user?.role === 'Admin' && (
        <div className="dashboard-section premium-card" style={{ marginBottom: '20px' }}>
          <h3>⚙️ Configuration des Cotisations</h3>
          <form className="config-form" onSubmit={handleConfigSave} style={{ display: 'flex', gap: '15px', flexWrap: 'wrap', marginTop: '15px' }}>
            <div className="input-field" style={{ flex: '1 1 200px' }}>
              <label>But de la cotisation</label>
              <input 
                type="text" 
                value={editConfig.purpose} 
                onChange={e => setEditConfig({...editConfig, purpose: e.target.value})} 
                required 
              />
            </div>
            <div className="input-field" style={{ flex: '1 1 150px' }}>
              <label>Montant (FCFA)</label>
              <input 
                type="number" 
                value={editConfig.amount} 
                onChange={e => setEditConfig({...editConfig, amount: e.target.value})} 
                required 
              />
            </div>
            <div className="input-field" style={{ flex: '1 1 150px' }}>
              <label>Date Limite</label>
              <input 
                type="date" 
                value={editConfig.dueDate} 
                onChange={e => setEditConfig({...editConfig, dueDate: e.target.value})} 
                required 
              />
            </div>
            <div style={{ display: 'flex', alignItems: 'flex-end', paddingBottom: '5px' }}>
              <button type="submit" className="primary-btn" disabled={isSavingConfig}>
                {isSavingConfig ? 'Enregistrement...' : 'Enregistrer'}
              </button>
            </div>
          </form>
        </div>
      )}

      {user?.role === 'Membre' && config && (
        <div className="stat-card premium-card blue" style={{ marginBottom: '20px', width: '100%', maxWidth: 'none', flexDirection: 'row', alignItems: 'center' }}>
          <div className="stat-icon" style={{ marginRight: '15px' }}><AlertCircle size={32} /></div>
          <div className="stat-info" style={{ flex: 1 }}>
            <h4>Objectif Actuel: {config.purpose}</h4>
            <div style={{ display: 'flex', gap: '20px', marginTop: '5px' }}>
              <p className="stat-value" style={{ fontSize: '18px' }}>Montant : {config.amount} FCFA</p>
              <p className="stat-value" style={{ fontSize: '18px', color: '#ffedd5' }}>Date limite : {new Date(config.dueDate).toLocaleDateString()}</p>
            </div>
          </div>
        </div>
      )}

      <div className="stats-grid">
        {user?.role === 'Admin' && (
          <StatCard 
            title="Total Utilisateurs" 
            value={stats.totalMembers} 
            icon={<Users size={24} />} 
            trend={`Dont ${stats.treasurerCount} Trésoriers`} 
            color="blue"
          />
        )}
        {user?.role === 'Membre' && (
          <StatCard 
            title="Ma Contribution Totale" 
            value={`${(stats.totalContributions || 0).toLocaleString()} FCFA`} 
            icon={<Wallet size={24} />} 
            trend="Membre Actif" 
            color="blue"
          />
        )}
        {user?.role !== 'Membre' && (
          <StatCard 
            title="Fonds Coopérative" 
            value={`${(stats.totalContributions || 0).toLocaleString()} FCFA`} 
            icon={<Wallet size={24} />} 
            trend="+12%" 
            color="purple"
          />
        )}
        <StatCard 
          title={user?.role === 'Membre' ? 'Prochain Paiement' : 'Cotisations du Mois'} 
            value={user?.role === 'Membre' ? '50 FCFA' : `${Math.round(stats.monthlyContributions || 0).toLocaleString()} FCFA`} 
          icon={<HandCoins size={24} />} 
          trend={user?.role === 'Membre' ? 'Dû le 1er' : '+2%'} 
          color="orange"
        />
        <StatCard 
          title="Alertes" 
          value={stats.latePayments} 
          icon={<AlertCircle size={24} />} 
          trend={stats.latePayments > 0 ? 'Urgent' : 'Sain'} 
          color="red"
        />
        {user?.role === 'Membre' && (
          <div className="stat-card premium-card orange">
            <div className="stat-info">
              <h4>Dette Totale</h4>
              <p className="stat-value">{(stats.totalDebt || 0).toLocaleString()} FCFA</p>
              <span className="stat-label">Virements approuvés</span>
            </div>
            <div className="stat-icon"><History size={24} /></div>
          </div>
        )}
      </div>

      {user?.role === 'Membre' && (
        <div className="member-actions-row">
          <button className="primary-btn pulse-btn" onClick={() => setIsModalOpen(true)}>
            <Wallet size={18} /> Demander un virement
          </button>
        </div>
      )}

      <TransferModal 
        isOpen={isModalOpen} 
        onClose={() => setIsModalOpen(false)} 
        onSubmit={handleTransferRequest}
      />

      <div className="dashboard-grid">
        <div className="dashboard-section members-section premium-card">
          <div className="section-header">
            <h3>Derniers Membres</h3>
            <button className="view-all">Voir tout <ArrowRight size={16} /></button>
          </div>
          <div className="members-table-wrapper">
            <table className="mini-table">
              <thead>
                <tr>
                  <th>Nom</th>
                  <th>Rôle</th>
                  <th>Statut</th>
                </tr>
              </thead>
              <tbody>
                {members.map(m => (
                  <tr key={m._id}>
                    <td>
                      <div className="member-cell">
                        <div className="avatar">{m.firstName?.[0] || '?'}</div>
                        <span>{m.firstName} {m.lastName}</span>
                      </div>
                    </td>
                    <td>{m.role}</td>
                    <td><span className="badge success">Actif</span></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>

        <div className="dashboard-section chart-section premium-card">
          <h3>Graphique des Contributions</h3>
          <div className="chart-container">
            <ResponsiveContainer width="100%" height={250}>
              <BarChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e2e8f0" />
                <XAxis dataKey="name" axisLine={false} tickLine={false} />
                <YAxis axisLine={false} tickLine={false} />
                <Tooltip 
                  contentStyle={{ borderRadius: '12px', border: 'none', boxShadow: '0 4px 6px -1px rgb(0 0 0 / 0.1)' }}
                />
                <Bar dataKey="value" fill="url(#colorGradient)" radius={[4, 4, 0, 0]} />
                <defs>
                  <linearGradient id="colorGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="0%" stopColor="#2563eb" />
                    <stop offset="100%" stopColor="#7c3aed" />
                  </linearGradient>
                </defs>
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        <div className="dashboard-section pie-section premium-card">
          <h3>Répartition des Fonds</h3>
          <div className="chart-container-pie">
            <ResponsiveContainer width="100%" height={200}>
              <PieChart>
                <Pie
                  data={pieData}
                  innerRadius={60}
                  outerRadius={80}
                  paddingAngle={5}
                  dataKey="value"
                >
                  {pieData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
            <div className="pie-legend">
              {pieData.map((d, i) => (
                <div key={d.name} className="legend-item">
                  <span className="dot" style={{ background: COLORS[i] }}></span>
                  <span>{d.name}</span>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

const StatCard = ({ title, value, icon, trend, color }) => (
  <div className={`stat-card premium-card ${color}`}>
    <div className="stat-icon">{icon}</div>
    <div className="stat-info">
      <h4>{title}</h4>
      <p className="stat-value">{value}</p>
      <div className={`stat-trend ${(trend || '').startsWith('+') ? 'up' : 'down'}`}>
        {(trend || '').startsWith('+') ? <ChevronUp size={16} /> : <ChevronDown size={16} />}
        <span>{trend}</span>
      </div>
    </div>
  </div>
);

export default Dashboard;
