const crypto = require('crypto');
const jwt = require('jsonwebtoken');

const signAccessToken = (user) =>
  jwt.sign(
    {
      sub: user._id.toString(),
      role: user.role,
    },
    process.env.JWT_ACCESS_SECRET,
    {
      expiresIn: process.env.JWT_ACCESS_EXPIRES_IN || '15m',
    }
  );

const signRefreshToken = (user) =>
  jwt.sign(
    {
      sub: user._id.toString(),
      role: user.role,
    },
    process.env.JWT_REFRESH_SECRET,
    {
      expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
    }
  );

const hashToken = (token) => crypto.createHash('sha256').update(token).digest('hex');

const setAuthCookies = (res, accessToken, refreshToken) => {
  const secure = process.env.NODE_ENV === 'production' || process.env.COOKIE_SECURE === 'true';
  const commonCookieOptions = {
    httpOnly: true,
    secure,
    sameSite: secure ? 'none' : 'lax',
  };

  res.cookie('accessToken', accessToken, {
    ...commonCookieOptions,
    maxAge: 15 * 60 * 1000,
  });

  res.cookie('refreshToken', refreshToken, {
    ...commonCookieOptions,
    maxAge: 7 * 24 * 60 * 60 * 1000,
  });
};

const clearAuthCookies = (res) => {
  res.clearCookie('accessToken');
  res.clearCookie('refreshToken');
};

const generateTokenPair = (user) => ({
  accessToken: signAccessToken(user),
  refreshToken: signRefreshToken(user),
});

module.exports = {
  clearAuthCookies,
  generateTokenPair,
  hashToken,
  setAuthCookies,
  signAccessToken,
  signRefreshToken,
};
