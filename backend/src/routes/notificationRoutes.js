const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const validateRequest = require('../middleware/validationMiddleware');
const { notificationIdValidation } = require('../validators/notificationValidators');
const {
  deleteNotification,
  getNotifications,
  markAllRead,
  markNotificationRead,
} = require('../controllers/notificationController');

const router = express.Router();

router.use(protect);

router.get('/', getNotifications);
router.patch('/read-all', markAllRead);
router.patch('/:id/read', notificationIdValidation, validateRequest, markNotificationRead);
router.delete('/:id', notificationIdValidation, validateRequest, deleteNotification);

module.exports = router;
