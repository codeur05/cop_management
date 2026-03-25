const Config = require('../models/Config');

// @desc    Get the current configuration
// @route   GET /api/config
// @access  Private (All authenticated users can view)
const getConfig = async (req, res, next) => {
  try {
    let config = await Config.findOne();
    
    // If no config exists, create a default one
    if (!config) {
      config = await Config.create({
        purpose: 'Non défini',
        amount: 0,
        dueDate: new Date(new Date().setMonth(new Date().getMonth() + 1)),
      });
    }

    res.json(config);
  } catch (error) {
    next(error);
  }
};

// @desc    Update or create configuration
// @route   POST /api/config
// @access  Private (Admin only)
const updateConfig = async (req, res, next) => {
  try {
    const { purpose, amount, dueDate } = req.body;

    let config = await Config.findOne();

    if (config) {
      // Update existing
      config.purpose = purpose !== undefined ? purpose : config.purpose;
      config.amount = amount !== undefined ? amount : config.amount;
      config.dueDate = dueDate ? new Date(dueDate) : config.dueDate;
      
      const updatedConfig = await config.save();
      return res.json(updatedConfig);
    } else {
      // Create new
      const newConfig = await Config.create({
        purpose: purpose || 'Non défini',
        amount: amount || 0,
        dueDate: dueDate ? new Date(dueDate) : new Date(),
      });
      return res.status(201).json(newConfig);
    }
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getConfig,
  updateConfig,
};
