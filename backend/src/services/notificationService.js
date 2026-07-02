const Notification = require('../models/Notification');

const createNotification = async ({ userId, title, message, type = 'system', meta = {} }) =>
  Notification.create({ userId, title, message, type, meta });

module.exports = {
  createNotification,
};
