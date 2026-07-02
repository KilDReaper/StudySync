const { body, param } = require('express-validator');

const goalIdValidation = [param('id').isMongoId().withMessage('Invalid goal id')];

const createGoalValidation = [
  body('title').trim().notEmpty().withMessage('Title is required'),
  body('targetHours').isFloat({ min: 0 }).withMessage('Target hours must be a positive number'),
  body('completedHours').optional().isFloat({ min: 0 }).withMessage('Completed hours must be a positive number'),
  body('deadline').isISO8601().withMessage('Deadline must be a valid date'),
];

const updateGoalValidation = [
  body('title').optional().trim().notEmpty().withMessage('Title cannot be empty'),
  body('targetHours').optional().isFloat({ min: 0 }).withMessage('Target hours must be a positive number'),
  body('completedHours').optional().isFloat({ min: 0 }).withMessage('Completed hours must be a positive number'),
  body('deadline').optional().isISO8601().withMessage('Deadline must be a valid date'),
];

const updateGoalProgressValidation = [
  body('completedHours').isFloat({ min: 0 }).withMessage('Completed hours must be a positive number'),
];

module.exports = {
  createGoalValidation,
  goalIdValidation,
  updateGoalProgressValidation,
  updateGoalValidation,
};
