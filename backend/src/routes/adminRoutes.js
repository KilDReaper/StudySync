const express = require('express');
const {
  submitReport,
  getUsers,
  deleteUser,
  getPlatformStats,
  getReports,
  updateReport,
} = require('../controllers/adminController');
const { protect } = require('../middleware/authMiddleware');
const { restrictTo } = require('../middleware/adminMiddleware');
const validateRequest = require('../middleware/validationMiddleware');
const {
  createReportValidation,
  updateReportValidation,
  userIdParamValidation,
} = require('../validators/adminValidators');

const router = express.Router();

router.use(protect);

router.post('/reports', createReportValidation, validateRequest, submitReport);

router.use(restrictTo('admin'));

router.get('/users', getUsers);
router.delete('/users/:id', userIdParamValidation, validateRequest, deleteUser);
router.get('/stats', getPlatformStats);
router.get('/reports', getReports);
router.patch('/reports/:id', updateReportValidation, validateRequest, updateReport);

module.exports = router;
