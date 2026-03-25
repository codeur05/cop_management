const express = require('express');
const router = express.Router();
const {
  createContribution,
  getContributions,
  getMyContributions,
  updateContribution,
  deleteContribution,
  getContributionStats,
} = require('../controllers/contributionController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.post('/', protect, authorize('Admin', 'Tresorier', 'Membre'), createContribution);
router.get('/', protect, authorize('Admin', 'Tresorier'), getContributions);
router.get('/my-contributions', protect, authorize('Membre'), getMyContributions);
router.get('/stats/summary', protect, authorize('Admin', 'Tresorier'), getContributionStats);
router.put('/:id', protect, authorize('Admin', 'Tresorier'), updateContribution);
router.delete('/:id', protect, authorize('Admin', 'Tresorier'), deleteContribution);

module.exports = router;
