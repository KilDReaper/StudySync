const express = require('express');
const {
  createStudySession,
  getStudySessions,
  getStudySession,
  updateStudySession,
  markComplete,
  deleteStudySession,
} = require('../controllers/studySessionController');
const { protect } = require('../middleware/authMiddleware');
const validateRequest = require('../middleware/validationMiddleware');
const {
  createSessionValidation,
  sessionIdValidation,
  updateSessionValidation,
} = require('../validators/studySessionValidators');

const router = express.Router();

router.use(protect);

router.route('/')
  .post(createSessionValidation, validateRequest, createStudySession)
  .get(getStudySessions);

router.route('/:id')
  .get(sessionIdValidation, validateRequest, getStudySession)
  .patch(updateSessionValidation, validateRequest, updateStudySession)
  .delete(sessionIdValidation, validateRequest, deleteStudySession);

router.patch('/:id/complete', sessionIdValidation, validateRequest, markComplete);

module.exports = router;
