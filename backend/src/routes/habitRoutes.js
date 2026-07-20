const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const validateRequest = require('../middleware/validationMiddleware');
const { createHabitValidation, habitIdValidation } = require('../validators/habitValidators');
const { createHabit, deleteHabit, getHabits, markHabitComplete, viewStreak } = require('../controllers/habitController');

const router = express.Router();

router.use(protect);

router.route('/')
  .post(createHabitValidation, validateRequest, createHabit)
  .get(getHabits);

router.patch('/:id/complete', habitIdValidation, validateRequest, markHabitComplete);
router.get('/:id/streak', habitIdValidation, validateRequest, viewStreak);
router.delete('/:id', habitIdValidation, validateRequest, deleteHabit);

module.exports = router;
