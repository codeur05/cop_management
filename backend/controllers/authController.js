const jwt = require('jsonwebtoken');
const User = require('../models/User');
const sendEmail = require('../utils/sendEmail');
const crypto = require('crypto');

// @desc    Register a new user
// @route   POST /api/auth/register
// @access  Public
const registerUser = async (req, res, next) => {
  try {
    const { firstName, lastName, email, password } = req.body;

    if (!firstName || !lastName || !email || !password) {
      return res.status(400).json({ message: 'Veuillez remplir tous les champs' });
    }

    // Check if user exists
    let user = await User.findOne({ email });

    if (user) {
      return res.status(400).json({ message: 'L\'utilisateur existe déjà' });
    }

    // Generate OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    // Determine role
    let role = 'Membre';
    if (email.toLowerCase().trim() === process.env.ADMIN_EMAIL?.toLowerCase().trim()) {
      role = 'Admin';
    }

    // Create user
    user = await User.create({
      firstName,
      lastName,
      email,
      password,
      role,
      otp,
      otpExpires,
      isVerified: false,
    });

    if (user) {
      console.log(`Nouvel utilisateur créé : ${user.email}. Tentative d'envoi d'OTP...`);
      // Send Email
      const message = `Votre code de vérification est : ${otp}. Il expire dans 10 minutes.`;
      console.log('DEBUG OTP:', message);
      try {
        await sendEmail({
          email: user.email,
          subject: 'Vérification de votre compte',
          message,
          html: `<h1>Vérification de compte</h1><p>${message}</p>`,
        });

        console.log(`OTP envoyé avec succès à : ${user.email}`);
        res.status(201).json({
          message: 'OTP envoyé',
          email: user.email,
        });
      } catch (err) {
        console.error('Email sending failed:', err);
        // We still created the user, they can use resend-otp
        res.status(201).json({
          message: 'Utilisateur créé, mais erreur lors de l\'envoi de l\'email. Veuillez demander un nouveau code.',
          email: user.email,
        });
      }
    } else {
      res.status(400).json({ message: 'Données utilisateur invalides' });
    }
  } catch (error) {
    next(error);
  }
};

// @desc    Authenticate a user
// @route   POST /api/auth/login
// @access  Public
const loginUser = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    console.log(`Tentative de connexion pour : ${email}`);

    // Check for user email
    const user = await User.findOne({ email }).select('+password');

    if (!user) {
      console.log('Utilisateur non trouvé');
      return res.status(401).json({ message: 'Email ou mot de passe incorrect' });
    }

    if (!user.isVerified) {
      return res.status(401).json({ message: 'Veuillez vérifier votre email' });
    }

    const isMatch = await user.matchPassword(password);
    console.log('Résultat comparaison mot de passe :', isMatch);

    if (isMatch) {
      res.json({
        token: generateToken(user._id),
        role: user.role,
        user: {
          id: user._id,
          firstName: user.firstName,
          lastName: user.lastName,
          email: user.email,
        },
      });
    } else {
      res.status(401).json({ message: 'Email ou mot de passe incorrect' });
    }
  } catch (error) {
    console.error('Erreur login :', error);
    next(error);
  }
};

// @desc    Verify OTP
// @route   POST /api/auth/verify-otp
// @access  Public
const verifyOTP = async (req, res, next) => {
  try {
    const { email, otp } = req.body;

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }

    if (user.isVerified) {
      return res.status(400).json({ message: 'Compte déjà vérifié' });
    }

    if (user.otp === otp && user.otpExpires > Date.now()) {
      await User.findOneAndUpdate(
        { email },
        { 
          isVerified: true, 
          $unset: { otp: 1, otpExpires: 1 } 
        }
      );

      res.status(200).json({ message: 'Email vérifié avec succès' });
    } else {
      res.status(400).json({ message: 'Code OTP invalide ou expiré' });
    }
  } catch (error) {
    next(error);
  }
};

// @desc    Resend OTP
// @route   POST /api/auth/resend-otp
// @access  Public
const resendOTP = async (req, res, next) => {
  try {
    const { email } = req.body;

    const user = await User.findOne({ email });

    if (!user) {
      return res.status(404).json({ message: 'Utilisateur non trouvé' });
    }

    if (user.isVerified) {
      return res.status(400).json({ message: 'Compte déjà vérifié' });
    }

    // Generate new OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const otpExpires = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes

    await User.findOneAndUpdate(
      { email },
      { 
        otp, 
        otpExpires 
      }
    );

    const message = `Votre nouveau code de vérification est : ${otp}. Il expire dans 10 minutes.`;
    console.log('DEBUG OTP (RESEND):', message);
    try {
      await sendEmail({
        email: user.email,
        subject: 'Nouveau code de vérification',
        message,
        html: `<h1>Vérification de compte</h1><p>${message}</p>`,
      });
      res.status(200).json({ message: 'Nouveau code OTP envoyé' });
    } catch (err) {
      console.error('Email sending failed during resend:', err);
      res.status(200).json({ 
        message: 'Nouveau code généré, mais erreur lors de l\'envoi de l\'email. Vérifiez la configuration du serveur.',
        success: true // Still true because OTP was updated in DB
      });
    }
  } catch (error) {
    next(error);
  }
};

// Generate JWT
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: '30d',
  });
};

module.exports = {
  registerUser,
  loginUser,
  verifyOTP,
  resendOTP,
};

