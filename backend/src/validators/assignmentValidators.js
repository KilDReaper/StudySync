const { body, param } = require('express-validator');

const assignmentIdValidation = [param('id').isMongoId().withMessage('Invalid assignment id')];

const createAssignmentValidation = [
  body('title').trim().notEmpty().withMessage('Title is required'),
  body('subject').trim().notEmpty().withMessage('Subject is required'),
  body('deadline').isISO8601().withMessage('Deadline must be a valid date'),
  body('progress').optional().isFloat({ min: 0, max: 100 }).withMessage('Progress must be between 0 and 100'),
  body('submissionStatus').optional().isIn(['not-submitted', 'submitted', 'graded']).withMessage('Invalid submission status'),
];

const updateAssignmentValidation = [
  body('title').optional().trim().notEmpty().withMessage('Title cannot be empty'),
  body('subject').optional().trim().notEmpty().withMessage('Subject cannot be empty'),
  body('deadline').optional().isISO8601().withMessage('Deadline must be a valid date'),
  body('progress').optional().isFloat({ min: 0, max: 100 }).withMessage('Progress must be between 0 and 100'),
  body('submissionStatus').optional().isIn(['not-submitted', 'submitted', 'graded']).withMessage('Invalid submission status'),
];

module.exports = {
  assignmentIdValidation,
  createAssignmentValidation,
  updateAssignmentValidation,
};
