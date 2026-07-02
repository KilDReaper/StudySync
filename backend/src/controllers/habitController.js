const Habit = require('../models/Habit');
const AppError = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');
const { buildPagination } = require('../utils/queryHelpers');
const { createNotification } = require('../services/notificationService');

const ownedQuery = (req, id) => (req.user.role === 'admin' ? { _id: id } : { _id: id, userId: req.user._id });

const normalizeDate = (date) => new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));

const recalculateHabitStreak = (completedDates) => {
  const uniqueDates = [...new Set(completedDates.map((date) => normalizeDate(new Date(date)).toISOString()))]
    .sort((a, b) => new Date(b) - new Date(a));

  if (!uniqueDates.length) {
    return 0;
  }

  let streak = 1;
  let previous = new Date(uniqueDates[0]);

  for (let index = 1; index < uniqueDates.length; index += 1) {
    const current = new Date(uniqueDates[index]);
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

const createHabit = catchAsync(async (req, res, next) => {
  const existingHabit = await Habit.findOne({ title: req.body.title, userId: req.user._id });
  if (existingHabit) {
    return next(new AppError('Habit already exists', 409));
  }

  const habit = await Habit.create({
    title: req.body.title,
    userId: req.user._id,
  });

  res.status(201).json({
    status: 'success',
    message: 'Habit created successfully',
    data: { habit },
  });
});

const getHabits = catchAsync(async (req, res) => {
  const { page, limit, skip } = buildPagination(req.query);
  const filter = { userId: req.user.role === 'admin' ? { $exists: true } : req.user._id };

  const [habits, total] = await Promise.all([
    Habit.find(filter).sort({ createdAt: -1 }).skip(skip).limit(limit),
    Habit.countDocuments(filter),
  ]);

  res.status(200).json({
    status: 'success',
    results: habits.length,
    pagination: { page, limit, total, pages: Math.ceil(total / limit) || 1 },
    data: { habits },
  });
});

const markHabitComplete = catchAsync(async (req, res, next) => {
  const habit = await Habit.findOne(ownedQuery(req, req.params.id));

  if (!habit) {
    return next(new AppError('Habit not found', 404));
  }

  const today = normalizeDate(new Date());
  const todayIso = today.toISOString();
  const dates = habit.completedDates.map((date) => normalizeDate(new Date(date)).toISOString());

  if (!dates.includes(todayIso)) {
    habit.completedDates.push(today);
    habit.lastCompletedAt = new Date();
  }

  habit.streakCount = recalculateHabitStreak(habit.completedDates);
  await habit.save();

  await createNotification({
    userId: habit.userId,
    title: 'Habit completed',
    message: `You completed the habit "${habit.title}" today.`,
    type: 'reminder',
    meta: { habitId: habit._id },
  });

  res.status(200).json({
    status: 'success',
    message: 'Habit marked as complete',
    data: { habit },
  });
});

const viewStreak = catchAsync(async (req, res, next) => {
  const habit = await Habit.findOne(ownedQuery(req, req.params.id));

  if (!habit) {
    return next(new AppError('Habit not found', 404));
  }

  res.status(200).json({
    status: 'success',
    data: {
      habitId: habit._id,
      title: habit.title,
      streakCount: habit.streakCount,
      completedDates: habit.completedDates,
      lastCompletedAt: habit.lastCompletedAt,
    },
  });
});

const deleteHabit = catchAsync(async (req, res, next) => {
  const habit = await Habit.findOneAndDelete(ownedQuery(req, req.params.id));

  if (!habit) {
    return next(new AppError('Habit not found', 404));
  }

  res.status(200).json({
    status: 'success',
    message: 'Habit deleted successfully',
  });
});

module.exports = {
  createHabit,
  deleteHabit,
  getHabits,
  markHabitComplete,
  viewStreak,
};
