const Contribution = require('../models/Contribution');

// @desc    Create a new contribution
// @route   POST /api/contributions
// @access  Private (Admin, Tresorier, Membre)
const createContribution = async (req, res, next) => {
  try {
    const { amount, type, status, member } = req.body;

    if (!amount || !type) {
      return res.status(400).json({ message: 'Veuillez ajouter un montant et un type' });
    }

    // Use member from body if admin/tresorier, otherwise use own id
    const targetMember = (req.user.role === 'Admin' || req.user.role === 'Tresorier') && member 
      ? member 
      : req.user._id;

    const contribution = await Contribution.create({
      member: targetMember,
      amount,
      type,
      status: status || 'Payé',
    });

    if (contribution) {
      res.status(201).json(contribution);
    } else {
      res.status(400).json({ message: 'Données de contribution invalides' });
    }
  } catch (error) {
    next(error);
  }
};

// @desc    Get all contributions
// @route   GET /api/contributions
// @access  Private/Admin/Tresorier
const getContributions = async (req, res, next) => {
  try {
    const contributions = await Contribution.find({}).populate(
      'member',
      'firstName lastName email'
    );
    res.json(contributions);
  } catch (error) {
    next(error);
  }
};

// @desc    Get logged in user contributions
// @route   GET /api/my-contributions
// @access  Private/Membre
const getMyContributions = async (req, res, next) => {
  try {
    const contributions = await Contribution.find({ member: req.user._id });
    res.json(contributions);
  } catch (error) {
    next(error);
  }
};

// @desc    Update a contribution
// @route   PUT /api/contributions/:id
// @access  Private/Admin/Tresorier
const updateContribution = async (req, res, next) => {
  try {
    const { amount, type, status } = req.body;
    const contribution = await Contribution.findById(req.params.id);

    if (contribution) {
      contribution.amount = amount || contribution.amount;
      contribution.type = type || contribution.type;
      contribution.status = status || contribution.status;
      
      const updatedContribution = await contribution.save();
      res.json(updatedContribution);
    } else {
      res.status(404).json({ message: 'Contribution non trouvée' });
    }
  } catch (error) {
    next(error);
  }
};

// @desc    Delete a contribution
// @route   DELETE /api/contributions/:id
// @access  Private/Admin/Tresorier
const deleteContribution = async (req, res, next) => {
  try {
    const contribution = await Contribution.findById(req.params.id);

    if (contribution) {
      await Contribution.findByIdAndDelete(req.params.id);
      res.json({ message: 'Contribution supprimée' });
    } else {
      res.status(404).json({ message: 'Contribution non trouvée' });
    }
  } catch (error) {
    next(error);
  }
};

// @desc    Get contribution stats for reports
// @route   GET /api/contributions/stats/summary
// @access  Private/Admin/Tresorier
const getContributionStats = async (req, res, next) => {
  try {
    const stats = await Contribution.aggregate([
      {
        $group: {
          _id: '$type',
          total: { $sum: '$amount' },
          count: { $sum: 1 },
        },
      },
    ]);

    const statusStats = await Contribution.aggregate([
      {
        $group: {
          _id: '$status',
          total: { $sum: '$amount' },
          count: { $sum: 1 },
        },
      },
    ]);

    res.json({ types: stats, status: statusStats });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createContribution,
  getContributions,
  getMyContributions,
  updateContribution,
  deleteContribution,
  getContributionStats,
};
