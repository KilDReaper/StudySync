const { body, param } = require('express-validator');

const userIdValidation = [param('id').isMongoId().withMessage('Invalid user id')];
const reportIdValidation = [param('id').isMongoId().withMessage('Invalid report id')];

const createReportValidation = [
  body('contentType').trim().notEmpty().withMessage('Content type is required'),
  body('contentId').isMongoId().withMessage('Content id must be a valid MongoDB id'),
  body('reason').trim().notEmpty().withMessage('Reason is required'),
];

const updateReportValidation = [
  body('status').isIn(['pending', 'reviewed', 'resolved', 'rejected']).withMessage('Invalid report status'),
  body('notes').optional().trim(),
];

module.exports = {
  createReportValidation,
  reportIdValidation,
  updateReportValidation,
  userIdValidation,
};
