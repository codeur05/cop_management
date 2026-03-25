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

// Trust proxy for Render/Cloudflare
app.set('trust proxy', 1);

// Body parser
app.use(express.json());

// Logger middleware
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});

// Enable CORS with explicit settings
app.use(cors({
  origin: true, // Reflect the request origin
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  credentials: true
}));

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

// TEMPORARY: Reset Admin Route
app.get('/api/auth/force-reset-admin', async (req, res) => {
  try {
    const bcrypt = require('bcryptjs');
    const User = require('./models/User');
    const email = 'efraimkantagba16@gmail.com';
    const password = 'Bonjour@2005';
    const hashedPassword = await bcrypt.hash(password, 10);

    const result = await User.findOneAndUpdate(
      { email: email },
      { 
        $set: { 
          password: hashedPassword,
          isVerified: true,
          role: 'Admin',
          firstName: 'Admin',
          lastName: 'Cooperative'
        } 
      },
      { upsert: true, new: true, runValidators: false }
    );

    res.send(`SUCCESS! Admin account ${email} is now ready! Password: ${password}`);
  } catch (error) {
    res.status(500).send(`Error: ${error.message}`);
  }
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
