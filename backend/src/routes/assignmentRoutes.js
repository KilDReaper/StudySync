const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const validateRequest = require('../middleware/validationMiddleware');
const { assignmentFileUpload } = require('../middleware/uploadMiddleware');
const {
  assignmentIdValidation,
  createAssignmentValidation,
  updateAssignmentValidation,
} = require('../validators/assignmentValidators');
const {
  createAssignment,
  deleteAssignment,
  getAssignment,
  getAssignments,
  updateAssignment,
  updateSubmissionStatus,
} = require('../controllers/assignmentController');

const router = express.Router();

router.use(protect);

router.get('/', getAssignments);
router.post('/', assignmentFileUpload, createAssignmentValidation, validateRequest, createAssignment);
router.get('/:id', assignmentIdValidation, validateRequest, getAssignment);
router.patch('/:id', assignmentFileUpload, assignmentIdValidation, updateAssignmentValidation, validateRequest, updateAssignment);
router.patch('/:id/status', assignmentIdValidation, validateRequest, updateSubmissionStatus);
router.delete('/:id', assignmentIdValidation, validateRequest, deleteAssignment);

module.exports = router;
