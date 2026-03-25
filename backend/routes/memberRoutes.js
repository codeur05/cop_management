const express = require('express');
const router = express.Router();
const { getMembers, updateMemberRole, deleteMember } = require('../controllers/memberController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.get('/', protect, authorize('Admin', 'Tresorier'), getMembers);
router.put('/:id/role', protect, authorize('Admin'), updateMemberRole);
router.delete('/:id', protect, authorize('Admin'), deleteMember);

module.exports = router;
