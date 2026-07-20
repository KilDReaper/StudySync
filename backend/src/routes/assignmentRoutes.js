const express = require('express');
const {
  createAssignment,
  getAssignments,
  getAssignment,
  updateAssignment,
  updateSubmissionStatus,
  deleteAssignment,
} = require('../controllers/assignmentController');
const { protect } = require('../middleware/authMiddleware');
const validateRequest = require('../middleware/validationMiddleware');
const upload = require('../middleware/uploadMiddleware');
const {
  createAssignmentValidation,
  assignmentIdValidation,
  updateAssignmentValidation,
  updateStatusValidation,
} = require('../validators/assignmentValidators');

const router = express.Router();

router.use(protect);

router.route('/')
  .post(upload.single('fileAttachment'), createAssignmentValidation, validateRequest, createAssignment)
  .get(getAssignments);

router.route('/:id')
  .get(assignmentIdValidation, validateRequest, getAssignment)
  .patch(upload.single('fileAttachment'), updateAssignmentValidation, validateRequest, updateAssignment)
  .delete(assignmentIdValidation, validateRequest, deleteAssignment);

router.patch('/:id/status', updateStatusValidation, validateRequest, updateSubmissionStatus);

module.exports = router;
