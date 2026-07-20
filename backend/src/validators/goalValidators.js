const { body, param } = require('express-validator');

const createGoalValidation = [
  body('title')
    .notEmpty()
    .withMessage('Title is required')
    .trim(),
  body('targetHours')
    .isFloat({ min: 0.1 })
    .withMessage('Target hours must be a number greater than 0'),
  body('completedHours')
    .optional()
    .isFloat({ min: 0 })
    .withMessage('Completed hours must be a positive number'),
  body('deadline')
    .isISO8601()
    .withMessage('Deadline must be a valid date'),
];

const goalIdValidation = [
  param('id')
    .isMongoId()
    .withMessage('Invalid goal ID'),
];

const updateGoalValidation = [
  ...goalIdValidation,
  body('title').optional().trim().notEmpty().withMessage('Title cannot be empty'),
  body('targetHours').optional().isFloat({ min: 0.1 }).withMessage('Target hours must be greater than 0'),
  body('deadline').optional().isISO8601().withMessage('Deadline must be a valid date'),
];

const updateProgressValidation = [
  ...goalIdValidation,
  body('completedHours')
    .isFloat({ min: 0 })
    .withMessage('Completed hours must be a positive number'),
];

module.exports = {
  createGoalValidation,
  goalIdValidation,
  updateGoalValidation,
  updateProgressValidation,
};
