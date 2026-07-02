const { body, param } = require('express-validator');

const sessionIdValidation = [param('id').isMongoId().withMessage('Invalid study session id')];

const createSessionValidation = [
  body('title').trim().notEmpty().withMessage('Title is required'),
  body('subject').trim().notEmpty().withMessage('Subject is required'),
  body('startTime').isISO8601().withMessage('Start time must be a valid date'),
  body('endTime').isISO8601().withMessage('End time must be a valid date'),
  body('priority').optional().isIn(['low', 'medium', 'high']).withMessage('Invalid priority value'),
  body('status').optional().isIn(['pending', 'completed']).withMessage('Invalid status value'),
];

const updateSessionValidation = [
  body('title').optional().trim().notEmpty().withMessage('Title cannot be empty'),
  body('subject').optional().trim().notEmpty().withMessage('Subject cannot be empty'),
  body('startTime').optional().isISO8601().withMessage('Start time must be a valid date'),
  body('endTime').optional().isISO8601().withMessage('End time must be a valid date'),
  body('priority').optional().isIn(['low', 'medium', 'high']).withMessage('Invalid priority value'),
  body('status').optional().isIn(['pending', 'completed']).withMessage('Invalid status value'),
];

module.exports = {
  createSessionValidation,
  sessionIdValidation,
  updateSessionValidation,
};
