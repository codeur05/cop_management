const mongoose = require('mongoose');

const contributionSchema = mongoose.Schema(
  {
    member: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    amount: {
      type: Number,
      required: [true, 'Veuillez ajouter un montant'],
    },
    type: {
      type: String,
      enum: ['Cotisation', 'Don'],
      required: [true, 'Veuillez spécifier le type (Cotisation ou Don)'],
    },
    date: {
      type: Date,
      default: Date.now,
    },
    status: {
      type: String,
      enum: ['Payé', 'En retard'],
      default: 'Payé',
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Contribution', contributionSchema);
