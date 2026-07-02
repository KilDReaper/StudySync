const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const adminMiddleware = require('../middleware/adminMiddleware');
const validateRequest = require('../middleware/validationMiddleware');
const {
  createReportValidation,
  reportIdValidation,
  updateReportValidation,
  userIdValidation,
} = require('../validators/adminValidators');
const {
  createReport,
  deleteUser,
  getPlatformStatistics,
  getReports,
  getUsers,
  updateReport,
} = require('../controllers/adminController');

const router = express.Router();

router.use(protect);

router.post('/reports', createReportValidation, validateRequest, createReport);
router.get('/users', adminMiddleware, getUsers);
router.delete('/users/:id', adminMiddleware, userIdValidation, validateRequest, deleteUser);
router.get('/stats', adminMiddleware, getPlatformStatistics);
router.get('/reports', adminMiddleware, getReports);
router.patch('/reports/:id', adminMiddleware, reportIdValidation, updateReportValidation, validateRequest, updateReport);

module.exports = router;
