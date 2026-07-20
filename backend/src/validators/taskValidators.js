const { body, param } = require('express-validator');

const createTaskValidation = [
  body('title')
    .notEmpty()
    .withMessage('Title is required')
    .trim(),
  body('dueDate')
    .isISO8601()
    .withMessage('Due date must be a valid date'),
  body('priority')
    .optional()
    .isIn(['low', 'medium', 'high'])
    .withMessage('Priority must be low, medium, or high'),
  body('status')
    .optional()
    .isIn(['pending', 'completed'])
    .withMessage('Status must be pending or completed'),
];

const taskIdValidation = [
  param('id')
    .isMongoId()
    .withMessage('Invalid task ID'),
];

const updateTaskValidation = [
  ...taskIdValidation,
  body('title').optional().trim().notEmpty().withMessage('Title cannot be empty'),
  body('dueDate').optional().isISO8601().withMessage('Due date must be a valid date'),
  body('priority').optional().isIn(['low', 'medium', 'high']).withMessage('Priority must be low, medium, or high'),
  body('status').optional().isIn(['pending', 'completed']).withMessage('Status must be pending or completed'),
];

module.exports = {
  createTaskValidation,
  taskIdValidation,
  updateTaskValidation,
};
