const { body, param } = require('express-validator');

const createSessionValidation = [
  body('title')
    .notEmpty()
    .withMessage('Title is required')
    .trim(),
  body('subject')
    .notEmpty()
    .withMessage('Subject is required')
    .trim(),
  body('startTime')
    .isISO8601()
    .withMessage('Start time must be a valid date'),
  body('endTime')
    .isISO8601()
    .withMessage('End time must be a valid date')
    .custom((value, { req }) => {
      if (new Date(value) <= new Date(req.body.startTime)) {
        throw new Error('End time must be after start time');
      }
      return true;
    }),
  body('priority')
    .optional()
    .isIn(['low', 'medium', 'high'])
    .withMessage('Priority must be low, medium, or high'),
];

const sessionIdValidation = [
  param('id')
    .isMongoId()
    .withMessage('Invalid session ID'),
];

const updateSessionValidation = [
  ...sessionIdValidation,
  body('title').optional().trim().notEmpty().withMessage('Title cannot be empty'),
  body('subject').optional().trim().notEmpty().withMessage('Subject cannot be empty'),
  body('startTime').optional().isISO8601().withMessage('Start time must be a valid date'),
  body('endTime').optional().isISO8601().withMessage('End time must be a valid date'),
];

module.exports = {
  createSessionValidation,
  sessionIdValidation,
  updateSessionValidation,
};
