const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const RefreshToken = require('../models/RefreshToken');
const AppError = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');
const { signAccessToken, signRefreshToken, sendTokenResponse } = require('../utils/tokens');
const { sendEmail } = require('../services/emailService');

const register = catchAsync(async (req, res, next) => {
  const { fullName, email, password } = req.body;

  const existingUser = await User.findOne({ email });
  if (existingUser) {
    return next(new AppError('Email address already in use', 409));
  }

  const isFirstUser = (await User.countDocuments({})) === 0;
  const role = isFirstUser ? 'admin' : 'student';

  const user = await User.create({
    fullName,
    email,
    password,
    role,
  });

  const accessToken = signAccessToken(user._id);
  const refreshToken = signRefreshToken(user._id);

  await RefreshToken.create({
    token: refreshToken,
    userId: user._id,
    expiresAt: new Date(Date.now() + (parseInt(process.env.JWT_REFRESH_EXPIRES_IN, 10) || 7) * 24 * 60 * 60 * 1000),
  });

  sendTokenResponse(res, 201, user, accessToken, refreshToken);
});

const login = catchAsync(async (req, res, next) => {
  const { email, password } = req.body;

  const user = await User.findOne({ email }).select('+password');
  if (!user || !(await user.comparePassword(password))) {
    return next(new AppError('Incorrect email or password', 401));
  }

  const accessToken = signAccessToken(user._id);
  const refreshToken = signRefreshToken(user._id);

  await RefreshToken.create({
    token: refreshToken,
    userId: user._id,
    expiresAt: new Date(Date.now() + (parseInt(process.env.JWT_REFRESH_EXPIRES_IN, 10) || 7) * 24 * 60 * 60 * 1000),
  });

  sendTokenResponse(res, 200, user, accessToken, refreshToken);
});

const logout = catchAsync(async (req, res) => {
  const refreshToken = req.cookies.refreshToken || req.body.refreshToken;

  if (refreshToken) {
    await RefreshToken.findOneAndDelete({ token: refreshToken });
  }

  res.clearCookie('refreshToken');
  res.status(200).json({
    status: 'success',
    message: 'Logged out successfully',
  });
});

const refreshToken = catchAsync(async (req, res, next) => {
  const token = req.cookies.refreshToken || req.body.refreshToken;

  if (!token) {
    return next(new AppError('Refresh token is required', 400));
  }

  const existingToken = await RefreshToken.findOne({ token });
  if (!existingToken || existingToken.expiresAt < new Date()) {
    if (existingToken) await RefreshToken.deleteOne({ _id: existingToken._id });
    return next(new AppError('Invalid or expired refresh token', 401));
  }

  let decoded;
  try {
    decoded = jwt.verify(token, process.env.JWT_REFRESH_SECRET);
  } catch (err) {
    return next(new AppError('Invalid or expired refresh token', 401));
  }

  const user = await User.findById(decoded.id);
  if (!user) {
    return next(new AppError('User not found', 404));
  }

  await RefreshToken.deleteOne({ _id: existingToken._id });

  const newAccessToken = signAccessToken(user._id);
  const newRefreshToken = signRefreshToken(user._id);

  await RefreshToken.create({
    token: newRefreshToken,
    userId: user._id,
    expiresAt: new Date(Date.now() + (parseInt(process.env.JWT_REFRESH_EXPIRES_IN, 10) || 7) * 24 * 60 * 60 * 1000),
  });

  sendTokenResponse(res, 200, user, newAccessToken, newRefreshToken);
});

const forgotPassword = catchAsync(async (req, res, next) => {
  const user = await User.findOne({ email: req.body.email });
  if (!user) {
    return next(new AppError('There is no user with that email address.', 404));
  }

  const resetToken = crypto.randomBytes(32).toString('hex');
  user.resetPasswordToken = crypto.createHash('sha256').update(resetToken).digest('hex');
  user.resetPasswordExpires = Date.now() + 10 * 60 * 1000;

  await user.save({ validateBeforeSave: false });

  const resetURL = `${process.env.RESET_PASSWORD_URL}/${resetToken}`;
  const message = `Forgot your password? Reset it here: ${resetURL}\nIf you didn't forget your password, please ignore this email!`;

  try {
    await sendEmail({
      email: user.email,
      subject: 'Your password reset token (valid for 10 mins)',
      message,
    });

    res.status(200).json({
      status: 'success',
      message: 'Password reset instructions sent to email',
    });
  } catch (err) {
    user.resetPasswordToken = undefined;
    user.resetPasswordExpires = undefined;
    await user.save({ validateBeforeSave: false });
    return next(new AppError('There was an error sending the email. Try again later.', 500));
  }
});

const resetPassword = catchAsync(async (req, res, next) => {
  const hashedToken = crypto.createHash('sha256').update(req.params.token).digest('hex');

  const user = await User.findOne({
    resetPasswordToken: hashedToken,
    resetPasswordExpires: { $gt: Date.now() },
  });

  if (!user) {
    return next(new AppError('Token is invalid or has expired', 400));
  }

  user.password = req.body.password;
  user.resetPasswordToken = undefined;
  user.resetPasswordExpires = undefined;
  user.passwordChangedAt = Date.now();
  await user.save();

  const accessToken = signAccessToken(user._id);
  const refreshToken = signRefreshToken(user._id);

  await RefreshToken.create({
    token: refreshToken,
    userId: user._id,
    expiresAt: new Date(Date.now() + (parseInt(process.env.JWT_REFRESH_EXPIRES_IN, 10) || 7) * 24 * 60 * 60 * 1000),
  });

  sendTokenResponse(res, 200, user, accessToken, refreshToken);
});

const getMe = catchAsync(async (req, res) => {
  res.status(200).json({
    status: 'success',
    data: {
      user: req.user,
    },
  });
});

const updateProfile = catchAsync(async (req, res, next) => {
  const { fullName, email } = req.body;
  const updates = {};

  if (fullName) updates.fullName = fullName;
  if (email) {
    const existing = await User.findOne({ email });
    if (existing && existing._id.toString() !== req.user._id.toString()) {
      return next(new AppError('Email address already in use', 409));
    }
    updates.email = email;
  }

  if (req.file) {
    updates.profilePicture = `/uploads/${req.file.filename}`;
  }

  const user = await User.findByIdAndUpdate(req.user._id, updates, {
    new: true,
    runValidators: true,
  });

  res.status(200).json({
    status: 'success',
    message: 'Profile updated successfully',
    data: { user },
  });
});

const changePassword = catchAsync(async (req, res, next) => {
  const { currentPassword, newPassword } = req.body;

  const user = await User.findById(req.user._id).select('+password');
  if (!(await user.comparePassword(currentPassword))) {
    return next(new AppError('Incorrect current password', 401));
  }

  user.password = newPassword;
  user.passwordChangedAt = Date.now();
  await user.save();

  const accessToken = signAccessToken(user._id);
  const refreshToken = signRefreshToken(user._id);

  await RefreshToken.create({
    token: refreshToken,
    userId: user._id,
    expiresAt: new Date(Date.now() + (parseInt(process.env.JWT_REFRESH_EXPIRES_IN, 10) || 7) * 24 * 60 * 60 * 1000),
  });

  sendTokenResponse(res, 200, user, accessToken, refreshToken);
});

module.exports = {
  register,
  login,
  logout,
  refreshToken,
  forgotPassword,
  resetPassword,
  getMe,
  updateProfile,
  changePassword,
};
