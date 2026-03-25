const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const connectDB = require('./config/db');

// Load env vars
dotenv.config();

const User = require('./models/User');

// Connect to database
connectDB().then(async () => {
  // Sync Admin role
  const adminEmail = process.env.ADMIN_EMAIL?.toLowerCase().trim();
  if (adminEmail) {
    await User.findOneAndUpdate(
      { email: adminEmail },
      { role: 'Admin' },
      { runValidators: false }
    );
    console.log(`Rôle Admin vérifié pour : ${adminEmail}`);
  }
});

const app = express();

// Body parser
app.use(express.json());

// Enable CORS
app.use(cors());

// Route files
const authRoutes = require('./routes/authRoutes');
const memberRoutes = require('./routes/memberRoutes');
const contributionRoutes = require('./routes/contributionRoutes');
const transferRoutes = require('./routes/transferRoutes');
const configRoutes = require('./routes/configRoutes');

// Mount routers
app.use('/api/auth', authRoutes);
app.use('/api/members', memberRoutes);
app.use('/api/contributions', contributionRoutes);
app.use('/api/transfers', transferRoutes);
app.use('/api/config', configRoutes);
app.use('/api', contributionRoutes); // For /api/my-contributions

// Base route
app.get('/', (req, res) => {
  res.send('Digital Cooperative Management API is running...');
});

// Error handling middleware (Bonus)
app.use((err, req, res, next) => {
  const statusCode = res.statusCode === 200 ? 500 : res.statusCode;
  res.status(statusCode).json({
    message: err.message,
    stack: process.env.NODE_ENV === 'production' ? null : err.stack,
  });
});

const PORT = process.env.PORT || 8000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running in ${process.env.NODE_ENV || 'development'} mode on port ${PORT}`);
});
