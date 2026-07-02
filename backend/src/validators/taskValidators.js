const { body, param, query } = require('express-validator');

const taskIdValidation = [param('id').isMongoId().withMessage('Invalid task id')];

const createTaskValidation = [
  body('title').trim().notEmpty().withMessage('Title is required'),
  body('description').optional().trim(),
  body('dueDate').optional().isISO8601().withMessage('Due date must be a valid date'),
  body('priority').optional().isIn(['low', 'medium', 'high']).withMessage('Invalid priority value'),
  body('status').optional().isIn(['pending', 'in-progress', 'completed']).withMessage('Invalid status value'),
];

const updateTaskValidation = [
  body('title').optional().trim().notEmpty().withMessage('Title cannot be empty'),
  body('description').optional().trim(),
  body('dueDate').optional().isISO8601().withMessage('Due date must be a valid date'),
  body('priority').optional().isIn(['low', 'medium', 'high']).withMessage('Invalid priority value'),
  body('status').optional().isIn(['pending', 'in-progress', 'completed']).withMessage('Invalid status value'),
];

const taskListValidation = [
  query('status').optional().isIn(['pending', 'in-progress', 'completed']).withMessage('Invalid status filter'),
  query('priority').optional().isIn(['low', 'medium', 'high']).withMessage('Invalid priority filter'),
];

module.exports = {
  createTaskValidation,
  taskIdValidation,
  taskListValidation,
  updateTaskValidation,
};
