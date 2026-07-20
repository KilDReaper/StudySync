const Assignment = require('../models/Assignment');
const AppError = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');
const { buildPagination } = require('../utils/queryHelpers');

const ownedQuery = (req, id) => (req.user.role === 'admin' ? { _id: id } : { _id: id, userId: req.user._id });

const createAssignment = catchAsync(async (req, res) => {
  const { title, subject, deadline, progress } = req.body;
  let fileAttachment = '';

  if (req.file) {
    fileAttachment = `/uploads/${req.file.filename}`;
  }

  const assignment = await Assignment.create({
    title,
    subject,
    deadline,
    progress: progress ? parseInt(progress, 10) : 0,
    fileAttachment,
    userId: req.user._id,
  });

  res.status(201).json({
    status: 'success',
    message: 'Assignment created successfully',
    data: { assignment },
  });
});

const getAssignments = catchAsync(async (req, res) => {
  const { page, limit, skip } = buildPagination(req.query);
  const filter = req.user.role === 'admin' ? {} : { userId: req.user._id };

  if (req.query.submissionStatus) {
    filter.submissionStatus = req.query.submissionStatus;
  }
  if (req.query.subject) {
    filter.subject = { $regex: req.query.subject, $options: 'i' };
  }

  const [assignments, total] = await Promise.all([
    Assignment.find(filter).sort({ deadline: 1 }).skip(skip).limit(limit),
    Assignment.countDocuments(filter),
  ]);

  res.status(200).json({
    status: 'success',
    results: assignments.length,
    pagination: { page, limit, total, pages: Math.ceil(total / limit) || 1 },
    data: { assignments },
  });
});

const getAssignment = catchAsync(async (req, res, next) => {
  const assignment = await Assignment.findOne(ownedQuery(req, req.params.id));
  if (!assignment) {
    return next(new AppError('Assignment not found', 404));
  }

  res.status(200).json({
    status: 'success',
    data: { assignment },
  });
});

const updateAssignment = catchAsync(async (req, res, next) => {
  const updates = { ...req.body };

  if (req.file) {
    updates.fileAttachment = `/uploads/${req.file.filename}`;
  }

  const assignment = await Assignment.findOneAndUpdate(
    ownedQuery(req, req.params.id),
    updates,
    { new: true, runValidators: true }
  );

  if (!assignment) {
    return next(new AppError('Assignment not found', 404));
  }

  res.status(200).json({
    status: 'success',
    message: 'Assignment updated successfully',
    data: { assignment },
  });
});

const updateSubmissionStatus = catchAsync(async (req, res, next) => {
  const { submissionStatus } = req.body;

  const assignment = await Assignment.findOneAndUpdate(
    ownedQuery(req, req.params.id),
    { submissionStatus },
    { new: true, runValidators: true }
  );

  if (!assignment) {
    return next(new AppError('Assignment not found', 404));
  }

  res.status(200).json({
    status: 'success',
    message: 'Submission status updated successfully',
    data: { assignment },
  });
});

const deleteAssignment = catchAsync(async (req, res, next) => {
  const assignment = await Assignment.findOneAndDelete(ownedQuery(req, req.params.id));
  if (!assignment) {
    return next(new AppError('Assignment not found', 404));
  }

  res.status(200).json({
    status: 'success',
    message: 'Assignment deleted successfully',
  });
});

module.exports = {
  createAssignment,
  getAssignments,
  getAssignment,
  updateAssignment,
  updateSubmissionStatus,
  deleteAssignment,
};
