const { body, param } = require('express-validator');

const createHabitValidation = [
  body('title')
    .notEmpty()
    .withMessage('Title is required')
    .trim(),
  body('icon')
    .optional()
    .trim(),
];

const habitIdValidation = [
  param('id')
    .isMongoId()
    .withMessage('Invalid habit ID'),
];

module.exports = {
  createHabitValidation,
  habitIdValidation,
};
