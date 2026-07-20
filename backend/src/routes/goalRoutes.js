const express = require('express');
const {
  createGoal,
  getGoals,
  updateGoal,
  updateGoalProgress,
  deleteGoal,
} = require('../controllers/goalController');
const { protect } = require('../middleware/authMiddleware');
const validateRequest = require('../middleware/validationMiddleware');
const {
  createGoalValidation,
  goalIdValidation,
  updateGoalValidation,
  updateProgressValidation,
} = require('../validators/goalValidators');

const router = express.Router();

router.use(protect);

router.route('/')
  .post(createGoalValidation, validateRequest, createGoal)
  .get(getGoals);

router.route('/:id')
  .patch(updateGoalValidation, validateRequest, updateGoal)
  .delete(goalIdValidation, validateRequest, deleteGoal);

router.patch('/:id/progress', updateProgressValidation, validateRequest, updateGoalProgress);

module.exports = router;
