const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const { getDashboardAnalytics } = require('../controllers/dashboardController');

const router = express.Router();

router.use(protect);

router.get('/analytics', getDashboardAnalytics);

module.exports = router;
