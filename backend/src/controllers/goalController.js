const Goal = require('../models/Goal');
const AppError = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');
const { buildPagination } = require('../utils/queryHelpers');

const ownedQuery = (req, id) => (req.user.role === 'admin' ? { _id: id } : { _id: id, userId: req.user._id });

const syncGoalState = (goal) => {
  goal.completedHours = Math.max(0, goal.completedHours);
  if (goal.completedHours >= goal.targetHours) {
    goal.completedHours = goal.targetHours;
    goal.isCompleted = true;
    if (!goal.completedAt) {
      goal.completedAt = new Date();
    }
  } else {
    goal.isCompleted = false;
    goal.completedAt = undefined;
  }
};

const createGoal = catchAsync(async (req, res) => {
  const goal = await Goal.create({
    ...req.body,
    userId: req.user._id,
  });
  syncGoalState(goal);
  await goal.save();

  res.status(201).json({
    status: 'success',
    message: 'Goal created successfully',
    data: { goal },
  });
});

const getGoals = catchAsync(async (req, res) => {
  const { page, limit, skip } = buildPagination(req.query);
  const filter = { userId: req.user.role === 'admin' ? { $exists: true } : req.user._id };

  if (req.query.search) filter.title = new RegExp(req.query.search, 'i');
  if (req.query.completed === 'true') filter.isCompleted = true;
  if (req.query.completed === 'false') filter.isCompleted = false;

  const sortBy = req.query.sortBy || 'deadline';
  const sortOrder = req.query.sortOrder === 'asc' ? 1 : -1;

  const [goals, total] = await Promise.all([
    Goal.find(filter).sort({ [sortBy]: sortOrder }).skip(skip).limit(limit),
    Goal.countDocuments(filter),
  ]);

  res.status(200).json({
    status: 'success',
    results: goals.length,
    pagination: { page, limit, total, pages: Math.ceil(total / limit) || 1 },
    data: { goals },
  });
});

const getGoal = catchAsync(async (req, res, next) => {
  const goal = await Goal.findOne(ownedQuery(req, req.params.id));

  if (!goal) {
    return next(new AppError('Goal not found', 404));
  }

  res.status(200).json({
    status: 'success',
    data: { goal },
  });
});

const updateGoal = catchAsync(async (req, res, next) => {
  const goal = await Goal.findOneAndUpdate(ownedQuery(req, req.params.id), req.body, {
    new: true,
    runValidators: true,
  });

  if (!goal) {
    return next(new AppError('Goal not found', 404));
  }

  syncGoalState(goal);
  await goal.save();

  res.status(200).json({
    status: 'success',
    message: 'Goal updated successfully',
    data: { goal },
  });
});

const updateGoalProgress = catchAsync(async (req, res, next) => {
  const goal = await Goal.findOne(ownedQuery(req, req.params.id));

  if (!goal) {
    return next(new AppError('Goal not found', 404));
  }

  goal.completedHours = req.body.completedHours;
  syncGoalState(goal);
  await goal.save();

  res.status(200).json({
    status: 'success',
    message: goal.isCompleted ? 'Goal completed successfully' : 'Goal progress updated successfully',
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
  deleteGoal,
  getGoal,
  getGoals,
  updateGoal,
  updateGoalProgress,
};
