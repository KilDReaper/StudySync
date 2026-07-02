const User = require('../models/User');
const StudySession = require('../models/StudySession');
const Task = require('../models/Task');
const Assignment = require('../models/Assignment');
const Goal = require('../models/Goal');
const Habit = require('../models/Habit');
const Notification = require('../models/Notification');
const Report = require('../models/Report');
const RefreshToken = require('../models/RefreshToken');
const AppError = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');
const { buildPagination } = require('../utils/queryHelpers');

const getUsers = catchAsync(async (req, res) => {
  const { page, limit, skip } = buildPagination(req.query);
  const filter = {};

  if (req.query.search) {
    filter.$or = [
      { fullName: new RegExp(req.query.search, 'i') },
      { email: new RegExp(req.query.search, 'i') },
    ];
  }

  const [users, total] = await Promise.all([
    User.find(filter).sort({ createdAt: -1 }).skip(skip).limit(limit),
    User.countDocuments(filter),
  ]);

  res.status(200).json({
    status: 'success',
    results: users.length,
    pagination: { page, limit, total, pages: Math.ceil(total / limit) || 1 },
    data: { users },
  });
});

const deleteUser = catchAsync(async (req, res, next) => {
  const user = await User.findById(req.params.id);

  if (!user) {
    return next(new AppError('User not found', 404));
  }

  await Promise.all([
    RefreshToken.deleteMany({ userId: user._id }),
    StudySession.deleteMany({ userId: user._id }),
    Task.deleteMany({ userId: user._id }),
    Assignment.deleteMany({ userId: user._id }),
    Goal.deleteMany({ userId: user._id }),
    Habit.deleteMany({ userId: user._id }),
    Notification.deleteMany({ userId: user._id }),
    Report.deleteMany({ reportedBy: user._id }),
    user.deleteOne(),
  ]);

  res.status(200).json({
    status: 'success',
    message: 'User deleted successfully',
  });
});

const getPlatformStatistics = catchAsync(async (_req, res) => {
  const [users, sessions, tasks, assignments, goals, habits, notifications, reports] = await Promise.all([
    User.countDocuments(),
    StudySession.countDocuments(),
    Task.countDocuments(),
    Assignment.countDocuments(),
    Goal.countDocuments(),
    Habit.countDocuments(),
    Notification.countDocuments(),
    Report.countDocuments(),
  ]);

  res.status(200).json({
    status: 'success',
    data: {
      users,
      sessions,
      tasks,
      assignments,
      goals,
      habits,
      notifications,
      reports,
    },
  });
});

const createReport = catchAsync(async (req, res) => {
  const report = await Report.create({
    reportedBy: req.user._id,
    contentType: req.body.contentType,
    contentId: req.body.contentId,
    reason: req.body.reason,
  });

  res.status(201).json({
    status: 'success',
    message: 'Report submitted successfully',
    data: { report },
  });
});

const getReports = catchAsync(async (req, res) => {
  const { page, limit, skip } = buildPagination(req.query);
  const filter = {};

  if (req.query.status) filter.status = req.query.status;
  if (req.query.contentType) filter.contentType = req.query.contentType;

  const [reports, total] = await Promise.all([
    Report.find(filter).sort({ createdAt: -1 }).skip(skip).limit(limit).populate('reportedBy', 'fullName email'),
    Report.countDocuments(filter),
  ]);

  res.status(200).json({
    status: 'success',
    results: reports.length,
    pagination: { page, limit, total, pages: Math.ceil(total / limit) || 1 },
    data: { reports },
  });
});

const updateReport = catchAsync(async (req, res, next) => {
  const report = await Report.findByIdAndUpdate(
    req.params.id,
    {
      status: req.body.status,
      notes: req.body.notes,
    },
    { new: true, runValidators: true }
  );

  if (!report) {
    return next(new AppError('Report not found', 404));
  }

  res.status(200).json({
    status: 'success',
    message: 'Report updated successfully',
    data: { report },
  });
});

module.exports = {
  createReport,
  deleteUser,
  getPlatformStatistics,
  getReports,
  getUsers,
  updateReport,
};
