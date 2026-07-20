const { body, param } = require('express-validator');

const habitIdValidation = [param('id').isMongoId().withMessage('Invalid habit id')];

const createHabitValidation = [
  body('title').trim().notEmpty().withMessage('Title is required'),
  body('icon').optional().trim(),
];

module.exports = {
  createHabitValidation,
  habitIdValidation,
};
