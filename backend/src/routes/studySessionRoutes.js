const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const validateRequest = require('../middleware/validationMiddleware');
const {
  createSessionValidation,
  sessionIdValidation,
  updateSessionValidation,
} = require('../validators/studySessionValidators');
const {
  createStudySession,
  deleteStudySession,
  getAllStudySessions,
  getStudySession,
  markSessionComplete,
  updateStudySession,
} = require('../controllers/studySessionController');

const router = express.Router();

router.use(protect);

router.get('/', getAllStudySessions);
router.post('/', createSessionValidation, validateRequest, createStudySession);
router.get('/:id', sessionIdValidation, validateRequest, getStudySession);
router.patch('/:id', sessionIdValidation, updateSessionValidation, validateRequest, updateStudySession);
router.patch('/:id/complete', sessionIdValidation, validateRequest, markSessionComplete);
router.delete('/:id', sessionIdValidation, validateRequest, deleteStudySession);

module.exports = router;
