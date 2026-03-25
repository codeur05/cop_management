const express = require('express');
const router = express.Router();
const {
  createTransferRequest,
  getTransferRequests,
  updateTransferStatus,
  getMyTransfers,
} = require('../controllers/transferController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.post('/', protect, createTransferRequest);
router.get('/', protect, authorize('Admin', 'Tresorier'), getTransferRequests);
router.get('/my-transfers', protect, getMyTransfers);
router.put('/:id/status', protect, authorize('Admin', 'Tresorier'), updateTransferStatus);

module.exports = router;
