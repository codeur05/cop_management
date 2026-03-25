const User = require('../models/User');

// @desc    Get all members
// @route   GET /api/members
// @access  Private/Admin
const getMembers = async (req, res, next) => {
  try {
    const members = await User.find({}).select('-password');
    res.json(members);
  } catch (error) {
    next(error);
  }
};

// @desc    Update user role
// @route   PUT /api/members/:id/role
// @access  Private/Admin
const updateMemberRole = async (req, res, next) => {
  try {
    const updatedUser = await User.findByIdAndUpdate(
      req.params.id, 
      { role: req.body.role }, 
      { new: true, runValidators: false }
    ).select('-password');

    if (updatedUser) {
      res.json(updatedUser);
    } else {
      res.status(404).json({ message: 'Utilisateur non trouvé' });
    }
  } catch (error) {
    next(error);
  }
};

// @desc    Delete a user
// @route   DELETE /api/members/:id
// @access  Private/Admin
const deleteMember = async (req, res, next) => {
  try {
    const user = await User.findById(req.params.id);

    if (user) {
      // Prevent deleting the last admin if needed, but for now simple delete
      await User.findByIdAndDelete(req.params.id);
      res.json({ message: 'Utilisateur supprimé avec succès' });
    } else {
      res.status(404).json({ message: 'Utilisateur non trouvé' });
    }
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getMembers,
  updateMemberRole,
  deleteMember,
};
