const TransferRequest = require('../models/TransferRequest');

// @desc    Create a transfer request
// @route   POST /api/transfers
// @access  Private
const createTransferRequest = async (req, res, next) => {
  try {
    const { amount } = req.body;

    if (!amount) {
      return res.status(400).json({ message: 'Veuillez ajouter un montant' });
    }

    const transfer = await TransferRequest.create({
      member: req.user._id,
      amount,
    });

    res.status(201).json(transfer);
  } catch (error) {
    next(error);
  }
};

// @desc    Get all transfer requests
// @route   GET /api/transfers
// @access  Private/Admin/Tresorier
const getTransferRequests = async (req, res, next) => {
  try {
    const transfers = await TransferRequest.find({})
      .populate('member', 'firstName lastName email')
      .sort({ createdAt: -1 });
    res.json(transfers);
  } catch (error) {
    next(error);
  }
};

// @desc    Update transfer request status
// @route   PUT /api/transfers/:id/status
// @access  Private/Admin/Tresorier
const updateTransferStatus = async (req, res, next) => {
  try {
    const { status } = req.body;
    
    if (!['Approuvé', 'Rejeté'].includes(status)) {
      return res.status(400).json({ message: 'Statut invalide' });
    }

    const transfer = await TransferRequest.findById(req.params.id);

    if (transfer) {
      transfer.status = status;
      const updatedTransfer = await transfer.save();
      res.json(updatedTransfer);
    } else {
      res.status(404).json({ message: 'Demande non trouvée' });
    }
  } catch (error) {
    next(error);
  }
};

// @desc    Get logged in user transfer requests
// @route   GET /api/transfers/my-transfers
// @access  Private
const getMyTransfers = async (req, res, next) => {
  try {
    const transfers = await TransferRequest.find({ member: req.user._id }).sort({ createdAt: -1 });
    res.json(transfers);
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createTransferRequest,
  getTransferRequests,
  updateTransferStatus,
  getMyTransfers,
};
