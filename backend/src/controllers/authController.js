const crypto = require('crypto');
const User = require('../models/User');
const RefreshToken = require('../models/RefreshToken');
const AppError = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');
const {
  clearAuthCookies,
  generateTokenPair,
  hashToken,
  setAuthCookies,
} = require('../utils/tokens');
const { sendPasswordResetEmail } = require('../services/emailService');

const refreshExpiryDays = 7;

const createAuthSession = async (user, req, res) => {
  const { accessToken, refreshToken } = generateTokenPair(user);
  const expiresAt = new Date(Date.now() + refreshExpiryDays * 24 * 60 * 60 * 1000);

  await RefreshToken.create({
    userId: user._id,
    tokenHash: hashToken(refreshToken),
    userAgent: req.get('user-agent') || '',
    ipAddress: req.ip,
    expiresAt,
  });

  setAuthCookies(res, accessToken, refreshToken);
  return { accessToken };
};

const sanitizeUser = (user) => user.toJSON();

const register = catchAsync(async (req, res) => {
  const { fullName, email, password } = req.body;

  const user = await User.create({
    fullName,
    email,
    password,
    profilePicture: req.file ? `/uploads/${req.file.filename}` : '',
  });

  const session = await createAuthSession(user, req, res);

  res.status(201).json({
    status: 'success',
    message: 'User registered successfully',
    accessToken: session.accessToken,
    data: {
      user: sanitizeUser(user),
    },
  });
});

const login = catchAsync(async (req, res, next) => {
  const { email, password } = req.body;
  const user = await User.findOne({ email }).select('+password');

  if (!user || !(await user.comparePassword(password))) {
    return next(new AppError('Invalid email or password', 401));
  }

  const session = await createAuthSession(user, req, res);

  res.status(200).json({
    status: 'success',
    message: 'Logged in successfully',
    accessToken: session.accessToken,
    data: {
      user: sanitizeUser(user),
    },
  });
});

const logout = catchAsync(async (req, res) => {
  const refreshToken = req.cookies?.refreshToken || req.body?.refreshToken;

  if (refreshToken) {
    await RefreshToken.findOneAndDelete({ tokenHash: hashToken(refreshToken) });
  }

  clearAuthCookies(res);
  res.status(200).json({
    status: 'success',
    message: 'Logged out successfully',
  });
});

const refreshToken = catchAsync(async (req, res, next) => {
  const token = req.cookies?.refreshToken || req.body?.refreshToken;

  if (!token) {
    return next(new AppError('Refresh token is required', 401));
  }

  let decoded;
  try {
    decoded = require('jsonwebtoken').verify(token, process.env.JWT_REFRESH_SECRET);
  } catch (error) {
    return next(error);
  }

  const tokenRecord = await RefreshToken.findOne({ tokenHash: hashToken(token), userId: decoded.sub });
  if (!tokenRecord || tokenRecord.revokedAt) {
    return next(new AppError('Refresh token is invalid or revoked', 401));
  }

  const user = await User.findById(decoded.sub);
  if (!user) {
    return next(new AppError('The user belonging to this token no longer exists.', 401));
  }

  await RefreshToken.findOneAndDelete({ _id: tokenRecord._id });
  const session = await createAuthSession(user, req, res);

  res.status(200).json({
    status: 'success',
    message: 'Token refreshed successfully',
    accessToken: session.accessToken,
  });
});

const forgotPassword = catchAsync(async (req, res) => {
  const { email } = req.body;
  const user = await User.findOne({ email });

  if (!user) {
    return res.status(200).json({
      status: 'success',
      message: 'If the email exists, password reset instructions have been sent',
    });
  }

  const resetToken = crypto.randomBytes(32).toString('hex');
  user.resetPasswordToken = crypto.createHash('sha256').update(resetToken).digest('hex');
  user.resetPasswordExpires = new Date(Date.now() + 15 * 60 * 1000);
  await user.save({ validateBeforeSave: false });

  const resetUrl = `${process.env.RESET_PASSWORD_URL || 'http://localhost:3000/reset-password'}?token=${resetToken}&email=${encodeURIComponent(user.email)}`;

  await sendPasswordResetEmail({
    to: user.email,
    resetUrl,
    name: user.fullName,
  });

  res.status(200).json({
    status: 'success',
    message: 'Password reset instructions sent',
  });
});

const resetPassword = catchAsync(async (req, res, next) => {
  const { token } = req.params;
  const { email, newPassword } = req.body;

  const hashedToken = crypto.createHash('sha256').update(token).digest('hex');
  const user = await User.findOne({
    email,
    resetPasswordToken: hashedToken,
    resetPasswordExpires: { $gt: Date.now() },
  }).select('+password');

  if (!user) {
    return next(new AppError('Reset token is invalid or expired', 400));
  }

  user.password = newPassword;
  user.resetPasswordToken = undefined;
  user.resetPasswordExpires = undefined;
  user.passwordChangedAt = new Date();
  await user.save();
  await RefreshToken.deleteMany({ userId: user._id });
  clearAuthCookies(res);

  res.status(200).json({
    status: 'success',
    message: 'Password reset successfully',
  });
});

const updateProfile = catchAsync(async (req, res, next) => {
  const updates = {};
  if (req.body.fullName) updates.fullName = req.body.fullName;
  if (req.body.email) updates.email = req.body.email;
  if (req.file) updates.profilePicture = `/uploads/${req.file.filename}`;

  const user = await User.findByIdAndUpdate(req.user._id, updates, {
    new: true,
    runValidators: true,
  });

  if (!user) {
    return next(new AppError('User not found', 404));
  }

  res.status(200).json({
    status: 'success',
    message: 'Profile updated successfully',
    data: {
      user: sanitizeUser(user),
    },
  });
});

const changePassword = catchAsync(async (req, res, next) => {
  const { currentPassword, newPassword } = req.body;
  const user = await User.findById(req.user._id).select('+password');

  if (!user) {
    return next(new AppError('User not found', 404));
  }

  const isValid = await user.comparePassword(currentPassword);
  if (!isValid) {
    return next(new AppError('Current password is incorrect', 400));
  }

  user.password = newPassword;
  user.passwordChangedAt = new Date();
  await user.save();
  await RefreshToken.deleteMany({ userId: user._id });

  const session = await createAuthSession(user, req, res);

  res.status(200).json({
    status: 'success',
    message: 'Password changed successfully',
    accessToken: session.accessToken,
  });
});

const getMe = catchAsync(async (req, res) => {
  const user = await User.findById(req.user._id);

  res.status(200).json({
    status: 'success',
    data: {
      user: sanitizeUser(user),
    },
  });
});

module.exports = {
  changePassword,
  forgotPassword,
  getMe,
  login,
  logout,
  refreshToken,
  register,
  resetPassword,
  updateProfile,
};
