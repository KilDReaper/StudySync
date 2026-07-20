const { body, param } = require('express-validator');

const createAssignmentValidation = [
  body('title')
    .notEmpty()
    .withMessage('Title is required')
    .trim(),
  body('subject')
    .notEmpty()
    .withMessage('Subject is required')
    .trim(),
  body('deadline')
    .isISO8601()
    .withMessage('Deadline must be a valid date'),
  body('progress')
    .optional()
    .isInt({ min: 0, max: 100 })
    .withMessage('Progress must be an integer between 0 and 100'),
];

const assignmentIdValidation = [
  param('id')
    .isMongoId()
    .withMessage('Invalid assignment ID'),
];

const updateAssignmentValidation = [
  ...assignmentIdValidation,
  body('title').optional().trim().notEmpty().withMessage('Title cannot be empty'),
  body('subject').optional().trim().notEmpty().withMessage('Subject cannot be empty'),
  body('deadline').optional().isISO8601().withMessage('Deadline must be a valid date'),
  body('progress').optional().isInt({ min: 0, max: 100 }).withMessage('Progress must be between 0 and 100'),
];

const updateStatusValidation = [
  ...assignmentIdValidation,
  body('submissionStatus')
    .isIn(['pending', 'submitted'])
    .withMessage('Status must be pending or submitted'),
];

module.exports = {
  createAssignmentValidation,
  assignmentIdValidation,
  updateAssignmentValidation,
  updateStatusValidation,
};
