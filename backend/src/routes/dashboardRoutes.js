const express = require('express');
const { getAnalytics } = require('../controllers/dashboardController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

router.use(protect);

router.get('/analytics', getAnalytics);

module.exports = router;
