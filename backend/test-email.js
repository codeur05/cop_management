const dotenv = require('dotenv');
const sendEmail = require('./utils/sendEmail');

dotenv.config();

const testEmail = async () => {
  try {
    console.log('Testing email delivery to: efraimkantagba16@gmail.com...');
    await sendEmail({
      email: 'efraimkantagba16@gmail.com',
      subject: 'Test Email from Cooperative App',
      message: 'This is a test email to verify OTP configuration.',
      html: '<h1>Test Email</h1><p>This is a test email to verify OTP configuration.</p>',
    });
    console.log('Test Email Sent Successfully!');
  } catch (error) {
    console.error('Test Email Failed:', error);
  }
};

testEmail();
