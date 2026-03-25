const mongoose = require('mongoose');

const transferRequestSchema = mongoose.Schema(
  {
    member: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
      ref: 'User',
    },
    amount: {
      type: Number,
      required: [true, 'Veuillez ajouter un montant'],
    },
    status: {
      type: String,
      enum: ['En attente', 'Approuvé', 'Rejeté'],
      default: 'En attente',
    },
    date: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('TransferRequest', transferRequestSchema);
