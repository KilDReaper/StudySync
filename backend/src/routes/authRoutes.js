const express = require('express');
const { body } = require('express-validator');
const validateRequest = require('../middleware/validationMiddleware');
const { profilePictureUpload } = require('../middleware/uploadMiddleware');
const { protect } = require('../middleware/authMiddleware');
const {
  changePasswordValidation,
  forgotPasswordValidation,
  loginValidation,
  registerValidation,
  resetPasswordValidation,
  updateProfileValidation,
} = require('../validators/authValidators');
const {
  changePassword,
  forgotPassword,
  getMe,
  login,
  logout,
  refreshToken,
  register,
  resetPassword,
  updateProfile,
} = require('../controllers/authController');

const router = express.Router();

router.post('/register', profilePictureUpload, registerValidation, validateRequest, register);
router.post('/login', loginValidation, validateRequest, login);
router.post('/logout', logout);
router.post('/refresh-token', refreshToken);
router.post('/forgot-password', forgotPasswordValidation, validateRequest, forgotPassword);
router.patch('/reset-password/:token', resetPasswordValidation, validateRequest, resetPassword);
router.get('/me', protect, getMe);
router.patch('/update-profile', protect, profilePictureUpload, updateProfileValidation, validateRequest, updateProfile);
router.patch('/change-password', protect, changePasswordValidation, validateRequest, changePassword);

module.exports = router;
