const express = require('express');
const router = express.Router();
const { getConfig, updateConfig } = require('../controllers/configController');
const { protect, authorize } = require('../middleware/authMiddleware');

// Anyone authenticated handles GET
router.get('/', protect, getConfig);

// Only Admin can handle POST (Update/Create)
router.post('/', protect, authorize('Admin'), updateConfig);

module.exports = router;
