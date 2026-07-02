const Task = require('../models/Task');
const AppError = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');
const { buildPagination } = require('../utils/queryHelpers');

const ownedQuery = (req, id) => (req.user.role === 'admin' ? { _id: id } : { _id: id, userId: req.user._id });

const createTask = catchAsync(async (req, res) => {
  const task = await Task.create({
    ...req.body,
    userId: req.user._id,
  });

  res.status(201).json({
    status: 'success',
    message: 'Task created successfully',
    data: { task },
  });
});

const getTasks = catchAsync(async (req, res) => {
  const { page, limit, skip } = buildPagination(req.query);
  const filter = { userId: req.user.role === 'admin' ? { $exists: true } : req.user._id };

  if (req.query.status) filter.status = req.query.status;
  if (req.query.priority) filter.priority = req.query.priority;
  if (req.query.search) {
    filter.$or = [
      { title: new RegExp(req.query.search, 'i') },
      { description: new RegExp(req.query.search, 'i') },
    ];
  }

  const sortBy = req.query.sortBy || 'createdAt';
  const sortOrder = req.query.sortOrder === 'asc' ? 1 : -1;

  const [tasks, total] = await Promise.all([
    Task.find(filter).sort({ [sortBy]: sortOrder }).skip(skip).limit(limit),
    Task.countDocuments(filter),
  ]);

  res.status(200).json({
    status: 'success',
    results: tasks.length,
    pagination: { page, limit, total, pages: Math.ceil(total / limit) || 1 },
    data: { tasks },
  });
});

const getTask = catchAsync(async (req, res, next) => {
  const task = await Task.findOne(ownedQuery(req, req.params.id));

  if (!task) {
    return next(new AppError('Task not found', 404));
  }

  res.status(200).json({
    status: 'success',
    data: { task },
  });
});

const updateTask = catchAsync(async (req, res, next) => {
  const task = await Task.findOneAndUpdate(ownedQuery(req, req.params.id), req.body, {
    new: true,
    runValidators: true,
  });

  if (!task) {
    return next(new AppError('Task not found', 404));
  }

  res.status(200).json({
    status: 'success',
    message: 'Task updated successfully',
    data: { task },
  });
});

const deleteTask = catchAsync(async (req, res, next) => {
  const task = await Task.findOneAndDelete(ownedQuery(req, req.params.id));

  if (!task) {
    return next(new AppError('Task not found', 404));
  }

  res.status(200).json({
    status: 'success',
    message: 'Task deleted successfully',
  });
});

module.exports = {
  createTask,
  deleteTask,
  getTask,
  getTasks,
  updateTask,
};
