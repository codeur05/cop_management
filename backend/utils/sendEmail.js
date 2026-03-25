const nodemailer = require('nodemailer');

const sendEmail = async (options) => {
  if (!process.env.EMAIL_USER || process.env.EMAIL_USER.includes('votre-email')) {
    console.warn('Email credentials not configured. Skipping email sending.');
    throw new Error('Email credentials not configured');
  }

  const transporter = nodemailer.createTransport({
    host: 'smtp.gmail.com',
    port: 465,
    secure: true,
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },
    tls: {
      rejectUnauthorized: false
    },
    // Force IPv4 because Render sometimes has issues with IPv6 resolution to Google
    lookup: (hostname, options, callback) => {
      require('dns').lookup(hostname, { family: 4 }, callback);
    }
  });

  const message = {
    from: `${process.env.FROM_NAME || 'Cooperative Management'} <${process.env.EMAIL_USER}>`,
    to: options.email,
    subject: options.subject,
    text: options.message,
    html: options.html,
  };

  try {
    const info = await transporter.sendMail(message);
    console.log('✅ Email envoyé avec succès ! MessageId: %s', info.messageId);
  } catch (err) {
    console.error('❌ ERREUR EMAIL DÉTAILLÉE :', err);
    throw err;
  }
};

module.exports = sendEmail;
