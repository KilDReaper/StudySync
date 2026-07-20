const User = require('../models/User');
const Report = require('../models/Report');
const StudySession = require('../models/StudySession');
const AppError = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');
const { buildPagination } = require('../utils/queryHelpers');

const submitReport = catchAsync(async (req, res) => {
  const { contentType, contentId, reason } = req.body;

  const report = await Report.create({
    contentType,
    contentId,
    reason,
    reporter: req.user._id,
  });

  res.status(201).json({
    status: 'success',
    message: 'Report submitted successfully',
    data: { report },
  });
});

const getUsers = catchAsync(async (req, res) => {
  const { page, limit, skip } = buildPagination(req.query);

  const [users, total] = await Promise.all([
    User.find().sort({ createdAt: -1 }).skip(skip).limit(limit),
    User.countDocuments(),
  ]);

  res.status(200).json({
    status: 'success',
    results: users.length,
    pagination: { page, limit, total, pages: Math.ceil(total / limit) || 1 },
    data: { users },
  });
});

const deleteUser = catchAsync(async (req, res, next) => {
  const user = await User.findByIdAndDelete(req.params.id);
  if (!user) {
    return next(new AppError('User not found', 404));
  }

  res.status(200).json({
    status: 'success',
    message: 'User deleted successfully',
  });
});

const getPlatformStats = catchAsync(async (req, res) => {
  const totalUsers = await User.countDocuments({ role: 'student' });
  const totalSessions = await StudySession.countDocuments();

  const userStats = await User.aggregate([
    {
      $group: {
        _id: null,
        totalHours: { $sum: '$totalStudyHours' },
        avgStreak: { $avg: '$studyStreak' },
      },
    },
  ]);

  const pendingReports = await Report.countDocuments({ status: 'pending' });

  res.status(200).json({
    status: 'success',
    data: {
      totalUsers,
      totalSessions,
      totalStudyHours: userStats[0] ? parseFloat(userStats[0].totalHours.toFixed(2)) : 0,
      averageStreak: userStats[0] ? parseFloat(userStats[0].avgStreak.toFixed(2)) : 0,
      pendingReports,
    },
  });
});

const getReports = catchAsync(async (req, res) => {
  const { page, limit, skip } = buildPagination(req.query);

  const [reports, total] = await Promise.all([
    Report.find().populate('reporter', 'fullName email').sort({ createdAt: -1 }).skip(skip).limit(limit),
    Report.countDocuments(),
  ]);

  res.status(200).json({
    status: 'success',
    results: reports.length,
    pagination: { page, limit, total, pages: Math.ceil(total / limit) || 1 },
    data: { reports },
  });
});

const updateReport = catchAsync(async (req, res, next) => {
  const { status, notes } = req.body;

  const report = await Report.findByIdAndUpdate(
    req.params.id,
    {
      status,
      notes,
      reviewedBy: req.user._id,
    },
    { new: true, runValidators: true }
  ).populate('reporter', 'fullName email');

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
  submitReport,
  getUsers,
  deleteUser,
  getPlatformStats,
  getReports,
  updateReport,
};
