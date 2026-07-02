const StudySession = require('../models/StudySession');
const User = require('../models/User');
const Notification = require('../models/Notification');
const AppError = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');
const { buildPagination } = require('../utils/queryHelpers');

const ownedQuery = (req, id) => (req.user.role === 'admin' ? { _id: id } : { _id: id, userId: req.user._id });

const recalculateStudyStreak = async (userId) => {
  const sessions = await StudySession.find({ userId, status: 'completed', completedAt: { $exists: true } })
    .select('completedAt')
    .lean();

  const uniqueDays = [...new Set(
    sessions
      .map((session) => new Date(session.completedAt).toISOString().slice(0, 10))
      .filter(Boolean)
  )].sort((a, b) => new Date(b) - new Date(a));

  if (!uniqueDays.length) {
    return 0;
  }

  let streak = 1;
  let previous = new Date(uniqueDays[0]);

  for (let index = 1; index < uniqueDays.length; index += 1) {
    const current = new Date(uniqueDays[index]);
    const diffInDays = Math.round((previous - current) / (1000 * 60 * 60 * 24));
    if (diffInDays === 1) {
      streak += 1;
      previous = current;
    } else {
      break;
    }
  }

  return streak;
};

const createStudySession = catchAsync(async (req, res, next) => {
  const { title, description, subject, startTime, endTime, priority, status } = req.body;

  if (new Date(endTime) <= new Date(startTime)) {
    return next(new AppError('End time must be after start time', 400));
  }

  const session = await StudySession.create({
    title,
    description,
    subject,
    startTime,
    endTime,
    priority,
    status,
    userId: req.user._id,
  });

  await Notification.create({
    userId: req.user._id,
    title: 'Study session scheduled',
    message: `Your study session "${title}" has been created.`,
    type: 'session',
    meta: { sessionId: session._id },
  });

  res.status(201).json({
    status: 'success',
    message: 'Study session created successfully',
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

const getAllStudySessions = catchAsync(async (req, res) => {
  const { page, limit, skip } = buildPagination(req.query);
  const filter = { userId: req.user.role === 'admin' ? { $exists: true } : req.user._id };

  if (req.query.status) filter.status = req.query.status;
  if (req.query.priority) filter.priority = req.query.priority;
  if (req.query.subject) filter.subject = new RegExp(req.query.subject, 'i');
  if (req.query.from || req.query.to) {
    filter.startTime = {};
    if (req.query.from) filter.startTime.$gte = new Date(req.query.from);
    if (req.query.to) filter.startTime.$lte = new Date(req.query.to);
  }

  const sortBy = req.query.sortBy || 'startTime';
  const sortOrder = req.query.sortOrder === 'asc' ? 1 : -1;

  const [sessions, total] = await Promise.all([
    StudySession.find(filter).sort({ [sortBy]: sortOrder }).skip(skip).limit(limit).populate('userId', 'fullName email role'),
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
  const session = await StudySession.findOne(ownedQuery(req, req.params.id)).populate('userId', 'fullName email role');

  if (!session) {
    return next(new AppError('Study session not found', 404));
  }

  res.status(200).json({
    status: 'success',
    data: { session },
  });
});

const markSessionComplete = catchAsync(async (req, res, next) => {
  const session = await StudySession.findOne(ownedQuery(req, req.params.id));

  if (!session) {
    return next(new AppError('Study session not found', 404));
  }

  if (session.status !== 'completed') {
    session.status = 'completed';
    session.completedAt = new Date();
    await session.save();

    const durationHours = Math.max(0, (new Date(session.endTime) - new Date(session.startTime)) / (1000 * 60 * 60));
    const streak = await recalculateStudyStreak(session.userId);

    await User.findByIdAndUpdate(session.userId, {
      $inc: { totalStudyHours: durationHours },
      studyStreak: streak,
    });
  }

  res.status(200).json({
    status: 'success',
    message: 'Study session marked as completed',
    data: { session },
  });
});

module.exports = {
  createStudySession,
  deleteStudySession,
  getAllStudySessions,
  getStudySession,
  markSessionComplete,
  updateStudySession,
};
