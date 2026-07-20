const express = require('express');
const {
  register,
  login,
  logout,
  refreshToken,
  forgotPassword,
  resetPassword,
  getMe,
  updateProfile,
  changePassword,
} = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');
const validateRequest = require('../middleware/validationMiddleware');
const upload = require('../middleware/uploadMiddleware');
const {
  registerValidation,
  loginValidation,
  forgotPasswordValidation,
  resetPasswordValidation,
  changePasswordValidation,
} = require('../validators/authValidators');

const router = express.Router();

router.post('/register', registerValidation, validateRequest, register);
router.post('/login', loginValidation, validateRequest, login);
router.post('/logout', logout);
router.post('/refresh-token', refreshToken);
router.post('/forgot-password', forgotPasswordValidation, validateRequest, forgotPassword);
router.patch('/reset-password/:token', resetPasswordValidation, validateRequest, resetPassword);

router.use(protect);
router.get('/me', getMe);
router.patch('/update-profile', upload.single('profilePicture'), updateProfile);
router.patch('/change-password', changePasswordValidation, validateRequest, changePassword);

module.exports = router;
