const Assignment = require('../models/Assignment');
const Notification = require('../models/Notification');
const AppError = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');
const { buildPagination } = require('../utils/queryHelpers');

const ownedQuery = (req, id) => (req.user.role === 'admin' ? { _id: id } : { _id: id, userId: req.user._id });

const mapFileAttachment = (file) => {
  if (!file) {
    return undefined;
  }

  return {
    url: `/uploads/${file.filename}`,
    filename: file.filename,
    mimetype: file.mimetype,
    size: file.size,
  };
};

const createAssignment = catchAsync(async (req, res) => {
  const assignment = await Assignment.create({
    ...req.body,
    fileAttachment: mapFileAttachment(req.file),
    submissionStatus: req.file ? 'submitted' : req.body.submissionStatus,
    userId: req.user._id,
  });

  await Notification.create({
    userId: req.user._id,
    title: 'Assignment created',
    message: `Assignment "${assignment.title}" has been added to your tracker.`,
    type: 'assignment',
    meta: { assignmentId: assignment._id },
  });

  res.status(201).json({
    status: 'success',
    message: 'Assignment created successfully',
    data: { assignment },
  });
});

const getAssignments = catchAsync(async (req, res) => {
  const { page, limit, skip } = buildPagination(req.query);
  const filter = { userId: req.user.role === 'admin' ? { $exists: true } : req.user._id };

  if (req.query.subject) filter.subject = new RegExp(req.query.subject, 'i');
  if (req.query.search) {
    filter.$or = [
      { title: new RegExp(req.query.search, 'i') },
      { subject: new RegExp(req.query.search, 'i') },
    ];
  }
  if (req.query.submissionStatus) filter.submissionStatus = req.query.submissionStatus;

  const sortBy = req.query.sortBy || 'deadline';
  const sortOrder = req.query.sortOrder === 'asc' ? 1 : -1;

  const [assignments, total] = await Promise.all([
    Assignment.find(filter).sort({ [sortBy]: sortOrder }).skip(skip).limit(limit),
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
  const update = { ...req.body };
  if (req.file) {
    update.fileAttachment = mapFileAttachment(req.file);
    update.submissionStatus = 'submitted';
  }

  const assignment = await Assignment.findOneAndUpdate(ownedQuery(req, req.params.id), update, {
    new: true,
    runValidators: true,
  });

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
  const assignment = await Assignment.findOneAndUpdate(
    ownedQuery(req, req.params.id),
    { submissionStatus: req.body.submissionStatus },
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
  deleteAssignment,
  getAssignment,
  getAssignments,
  updateAssignment,
  updateSubmissionStatus,
};
