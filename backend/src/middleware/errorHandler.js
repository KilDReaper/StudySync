const AppError = require('../utils/AppError');

const notFound = (req, _res, next) => {
  next(new AppError(`Route not found: ${req.originalUrl}`, 404));
};

const errorHandler = (err, req, res, _next) => {
  const statusCode = err.statusCode || 500;
  const response = {
    status: err.status || 'error',
    message: err.message || 'Internal server error',
  };

  if (process.env.NODE_ENV !== 'production') {
    response.stack = err.stack;
    response.path = req.originalUrl;
  }

  if (err.name === 'ValidationError') {
    response.status = 'fail';
    response.message = Object.values(err.errors)
      .map((item) => item.message)
      .join('. ');
  }

  if (err.code === 11000) {
    response.status = 'fail';
    response.message = 'Duplicate field value. Please use another value.';
  }

  if (err.name === 'CastError') {
    response.status = 'fail';
    response.message = `Invalid ${err.path}: ${err.value}`;
  }

  if (err.name === 'JsonWebTokenError') {
    response.status = 'fail';
    response.message = 'Invalid token. Please log in again.';
  }

  if (err.name === 'TokenExpiredError') {
    response.status = 'fail';
    response.message = 'Token expired. Please log in again.';
  }

  return res.status(statusCode).json(response);
};

module.exports = {
  errorHandler,
  notFound,
};
