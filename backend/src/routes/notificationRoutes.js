const express = require('express');
const {
  getNotifications,
  markAsRead,
  markAllAsRead,
  deleteNotification,
} = require('../controllers/notificationController');
const { protect } = require('../middleware/authMiddleware');
const validateRequest = require('../middleware/validationMiddleware');
const { notificationIdValidation } = require('../validators/notificationValidators');

const router = express.Router();

router.use(protect);

router.get('/', getNotifications);
router.patch('/read-all', markAllAsRead);
router.patch('/:id/read', notificationIdValidation, validateRequest, markAsRead);
router.delete('/:id', notificationIdValidation, validateRequest, deleteNotification);

module.exports = router;
