const StudySession = require('../models/StudySession');
const User = require('../models/User');
const AppError = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');
const { buildPagination } = require('../utils/queryHelpers');

const ownedQuery = (req, id) => (req.user.role === 'admin' ? { _id: id } : { _id: id, userId: req.user._id });

const createStudySession = catchAsync(async (req, res, next) => {
  const { title, description, subject, startTime, endTime, priority } = req.body;

  const session = await StudySession.create({
    title,
    description,
    subject,
    startTime,
    endTime,
    priority,
    userId: req.user._id,
  });

  res.status(201).json({
    status: 'success',
    message: 'Study session created successfully',
    data: { session },
  });
});

const getStudySessions = catchAsync(async (req, res) => {
  const { page, limit, skip } = buildPagination(req.query);
  const filter = req.user.role === 'admin' ? {} : { userId: req.user._id };

  if (req.query.status) {
    filter.completed = req.query.status === 'completed';
  }
  if (req.query.priority) {
    filter.priority = req.query.priority;
  }
  if (req.query.subject) {
    filter.subject = { $regex: req.query.subject, $options: 'i' };
  }

  const [sessions, total] = await Promise.all([
    StudySession.find(filter).sort({ startTime: -1 }).skip(skip).limit(limit),
    StudySession.countDocuments(filter),
  ]);

  res.status(200).json({
    status: 'success',
    results: sessions.length,
    pagination: { page, limit, total, pages: Math.ceil(total / limit) || 1 },
    data: { sessions },
  });
});

const getStudySession = catchAsync(async (req, res, next) => {
  const session = await StudySession.findOne(ownedQuery(req, req.params.id));
  if (!session) {
    return next(new AppError('Study session not found', 404));
  }

  res.status(200).json({
    status: 'success',
    data: { session },
  });
});

const updateStudySession = catchAsync(async (req, res, next) => {
  const session = await StudySession.findOneAndUpdate(
    ownedQuery(req, req.params.id),
    req.body,
    { new: true, runValidators: true }
  );

  if (!session) {
    return next(new AppError('Study session not found', 404));
  }

  res.status(200).json({
    status: 'success',
    message: 'Study session updated successfully',
    data: { session },
  });
});

const markComplete = catchAsync(async (req, res, next) => {
  const session = await StudySession.findOne(ownedQuery(req, req.params.id));

  if (!session) {
    return next(new AppError('Study session not found', 404));
  }

  if (session.completed) {
    return next(new AppError('Study session already completed', 400));
  }

  session.completed = true;
  await session.save();

  const durationMs = new Date(session.endTime) - new Date(session.startTime);
  const durationHours = parseFloat((durationMs / (1000 * 60 * 60)).toFixed(2));

  const user = await User.findById(session.userId);
  if (user) {
    user.totalStudyHours += durationHours;
    user.studyStreak += 1;
    await user.save();
  }

  res.status(200).json({
    status: 'success',
    message: 'Study session marked as completed',
    data: { session },
  });
});

const deleteStudySession = catchAsync(async (req, res, next) => {
  const session = await StudySession.findOneAndDelete(ownedQuery(req, req.params.id));
  if (!session) {
    return next(new AppError('Study session not found', 404));
  }

  res.status(200).json({
    status: 'success',
    message: 'Study session deleted successfully',
  });
});

module.exports = {
  createStudySession,
  getStudySessions,
  getStudySession,
  updateStudySession,
  markComplete,
  deleteStudySession,
};
