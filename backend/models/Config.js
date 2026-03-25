const mongoose = require('mongoose');

const configSchema = new mongoose.Schema(
  {
    purpose: {
      type: String,
      required: true,
      default: 'Achat de matériel agricole',
    },
    amount: {
      type: Number,
      required: true,
      default: 5000,
    },
    dueDate: {
      type: Date,
      required: true,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

const Config = mongoose.model('Config', configSchema);

module.exports = Config;
