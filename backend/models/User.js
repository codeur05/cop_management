const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = mongoose.Schema(
  {
    firstName: {
      type: String,
      required: [true, 'Veuillez ajouter un prénom'],
    },
    lastName: {
      type: String,
      required: [true, 'Veuillez ajouter un nom'],
    },
    email: {
      type: String,
      required: [true, 'Veuillez ajouter un email'],
      unique: true,
      match: [
        /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/,
        'Veuillez ajouter un email valide',
      ],
    },
    password: {
      type: String,
      required: [true, 'Veuillez ajouter un mot de passe'],
      minlength: 6,
      select: false,
    },
    role: {
      type: String,
      enum: ['Admin', 'Tresorier', 'Membre'],
      default: 'Membre',
    },
    isVerified: {
      type: Boolean,
      default: false,
    },
    otp: {
      type: String,
    },
    otpExpires: {
      type: Date,
    },
  },
  {
    timestamps: true,
  }
);

// Hash password before saving
userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) {
    return next();
  }
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

// Match user entered password to hashed password in database
userSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

module.exports = mongoose.model('User', userSchema);
