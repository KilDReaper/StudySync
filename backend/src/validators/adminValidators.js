const { body, param } = require('express-validator');

const createReportValidation = [
  body('contentType')
    .isIn(['task', 'session', 'habit', 'assignment'])
    .withMessage('Content type must be task, session, habit, or assignment'),
  body('contentId')
    .isMongoId()
    .withMessage('Invalid content ID'),
  body('reason')
    .notEmpty()
    .withMessage('Reason is required')
    .trim(),
];

const updateReportValidation = [
  param('id')
    .isMongoId()
    .withMessage('Invalid report ID'),
  body('status')
    .isIn(['reviewed', 'resolved'])
    .withMessage('Status must be reviewed or resolved'),
  body('notes')
    .optional()
    .trim(),
];

const userIdParamValidation = [
  param('id')
    .isMongoId()
    .withMessage('Invalid user ID'),
];

module.exports = {
  createReportValidation,
  updateReportValidation,
  userIdParamValidation,
};
