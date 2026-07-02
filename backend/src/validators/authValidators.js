const { body, param } = require('express-validator');

const registerValidation = [
  body('fullName').trim().isLength({ min: 2 }).withMessage('Full name must be at least 2 characters'),
  body('email').isEmail().withMessage('Please provide a valid email address').normalizeEmail(),
  body('password').isLength({ min: 8 }).withMessage('Password must be at least 8 characters'),
];

const loginValidation = [
  body('email').isEmail().withMessage('Please provide a valid email address').normalizeEmail(),
  body('password').notEmpty().withMessage('Password is required'),
];

const forgotPasswordValidation = [body('email').isEmail().withMessage('Please provide a valid email address').normalizeEmail()];

const resetPasswordValidation = [
  param('token').notEmpty().withMessage('Reset token is required'),
  body('email').isEmail().withMessage('Please provide a valid email address').normalizeEmail(),
  body('newPassword').isLength({ min: 8 }).withMessage('New password must be at least 8 characters'),
];

const updateProfileValidation = [
  body('fullName').optional().trim().isLength({ min: 2 }).withMessage('Full name must be at least 2 characters'),
  body('email').optional().isEmail().withMessage('Please provide a valid email address').normalizeEmail(),
];

const changePasswordValidation = [
  body('currentPassword').notEmpty().withMessage('Current password is required'),
  body('newPassword').isLength({ min: 8 }).withMessage('New password must be at least 8 characters'),
];

module.exports = {
  changePasswordValidation,
  forgotPasswordValidation,
  loginValidation,
  registerValidation,
  resetPasswordValidation,
  updateProfileValidation,
};
