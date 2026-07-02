const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const validateRequest = require('../middleware/validationMiddleware');
const {
  createGoalValidation,
  goalIdValidation,
  updateGoalProgressValidation,
  updateGoalValidation,
} = require('../validators/goalValidators');
const { createGoal, deleteGoal, getGoal, getGoals, updateGoal, updateGoalProgress } = require('../controllers/goalController');

const router = express.Router();

router.use(protect);

router.get('/', getGoals);
router.post('/', createGoalValidation, validateRequest, createGoal);
router.get('/:id', goalIdValidation, validateRequest, getGoal);
router.patch('/:id', goalIdValidation, updateGoalValidation, validateRequest, updateGoal);
router.patch('/:id/progress', goalIdValidation, updateGoalProgressValidation, validateRequest, updateGoalProgress);
router.delete('/:id', goalIdValidation, validateRequest, deleteGoal);

module.exports = router;
