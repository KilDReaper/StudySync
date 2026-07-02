const Notification = require('../models/Notification');
const AppError = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');
const { buildPagination } = require('../utils/queryHelpers');

const ownedQuery = (req, id) => (req.user.role === 'admin' ? { _id: id } : { _id: id, userId: req.user._id });

const getNotifications = catchAsync(async (req, res) => {
  const { page, limit, skip } = buildPagination(req.query);
  const filter = { userId: req.user.role === 'admin' ? { $exists: true } : req.user._id };

  if (req.query.type) filter.type = req.query.type;
  if (req.query.readStatus === 'true') filter.readStatus = true;
  if (req.query.readStatus === 'false') filter.readStatus = false;

  const [notifications, total] = await Promise.all([
    Notification.find(filter).sort({ createdAt: -1 }).skip(skip).limit(limit),
    Notification.countDocuments(filter),
  ]);

  res.status(200).json({
    status: 'success',
    results: notifications.length,
    pagination: { page, limit, total, pages: Math.ceil(total / limit) || 1 },
    data: { notifications },
  });
});

const markNotificationRead = catchAsync(async (req, res, next) => {
  const notification = await Notification.findOneAndUpdate(
    ownedQuery(req, req.params.id),
    { readStatus: true },
    { new: true }
  );

  if (!notification) {
    return next(new AppError('Notification not found', 404));
  }

  res.status(200).json({
    status: 'success',
    message: 'Notification marked as read',
    data: { notification },
  });
});

const markAllRead = catchAsync(async (req, res) => {
  const filter = req.user.role === 'admin' ? {} : { userId: req.user._id };
  const result = await Notification.updateMany(filter, { readStatus: true });

  res.status(200).json({
    status: 'success',
    message: 'All notifications marked as read',
    data: { modifiedCount: result.modifiedCount },
  });
});

const deleteNotification = catchAsync(async (req, res, next) => {
  const notification = await Notification.findOneAndDelete(ownedQuery(req, req.params.id));

  if (!notification) {
    return next(new AppError('Notification not found', 404));
  }

  res.status(200).json({
    status: 'success',
    message: 'Notification deleted successfully',
  });
});

module.exports = {
  deleteNotification,
  getNotifications,
  markAllRead,
  markNotificationRead,
};
