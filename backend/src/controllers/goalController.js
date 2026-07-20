const Goal = require('../models/Goal');
const AppError = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');
const { buildPagination } = require('../utils/queryHelpers');

const ownedQuery = (req, id) => (req.user.role === 'admin' ? { _id: id } : { _id: id, userId: req.user._id });

const createGoal = catchAsync(async (req, res) => {
  const { title, targetHours, completedHours, deadline } = req.body;

  const goal = await Goal.create({
    title,
    targetHours,
    completedHours: completedHours || 0,
    deadline,
    userId: req.user._id,
  });

  res.status(201).json({
    status: 'success',
    message: 'Goal created successfully',
    data: { goal },
  });
});

const getGoals = catchAsync(async (req, res) => {
  const { page, limit, skip } = buildPagination(req.query);
  const filter = req.user.role === 'admin' ? {} : { userId: req.user._id };

  const [goals, total] = await Promise.all([
    Goal.find(filter).sort({ deadline: 1 }).skip(skip).limit(limit),
    Goal.countDocuments(filter),
  ]);

  res.status(200).json({
    status: 'success',
    results: goals.length,
    pagination: { page, limit, total, pages: Math.ceil(total / limit) || 1 },
    data: { goals },
  });
});

const updateGoal = catchAsync(async (req, res, next) => {
  const goal = await Goal.findOneAndUpdate(
    ownedQuery(req, req.params.id),
    req.body,
    { new: true, runValidators: true }
  );

  if (!goal) {
    return next(new AppError('Goal not found', 404));
  }

  res.status(200).json({
    status: 'success',
    message: 'Goal updated successfully',
    data: { goal },
  });
});

const updateGoalProgress = catchAsync(async (req, res, next) => {
  const { completedHours } = req.body;

  const goal = await Goal.findOneAndUpdate(
    ownedQuery(req, req.params.id),
    { completedHours },
    { new: true, runValidators: true }
  );

  if (!goal) {
    return next(new AppError('Goal not found', 404));
  }

  res.status(200).json({
    status: 'success',
    message: 'Goal progress updated successfully',
    data: { goal },
  });
});

const deleteGoal = catchAsync(async (req, res, next) => {
  const goal = await Goal.findOneAndDelete(ownedQuery(req, req.params.id));
  if (!goal) {
    return next(new AppError('Goal not found', 404));
  }

  res.status(200).json({
    status: 'success',
    message: 'Goal deleted successfully',
  });
});

module.exports = {
  createGoal,
  getGoals,
  updateGoal,
  updateGoalProgress,
  deleteGoal,
};
