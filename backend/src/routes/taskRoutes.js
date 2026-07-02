const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const validateRequest = require('../middleware/validationMiddleware');
const {
  createTaskValidation,
  taskIdValidation,
  taskListValidation,
  updateTaskValidation,
} = require('../validators/taskValidators');
const { createTask, deleteTask, getTask, getTasks, updateTask } = require('../controllers/taskController');

const router = express.Router();

router.use(protect);

router.get('/', taskListValidation, validateRequest, getTasks);
router.post('/', createTaskValidation, validateRequest, createTask);
router.get('/:id', taskIdValidation, validateRequest, getTask);
router.patch('/:id', taskIdValidation, updateTaskValidation, validateRequest, updateTask);
router.delete('/:id', taskIdValidation, validateRequest, deleteTask);

module.exports = router;
