const { restrictTo } = require('./authMiddleware');

module.exports = restrictTo('admin');
