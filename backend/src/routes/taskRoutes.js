const express = require('express');
const {
  createTask,
  getTasks,
  getTask,
  updateTask,
  deleteTask,
} = require('../controllers/taskController');
const { protect } = require('../middleware/authMiddleware');
const validateRequest = require('../middleware/validationMiddleware');
const {
  createTaskValidation,
  taskIdValidation,
  updateTaskValidation,
} = require('../validators/taskValidators');

const router = express.Router();

router.use(protect);

router.route('/')
  .post(createTaskValidation, validateRequest, createTask)
  .get(getTasks);

router.route('/:id')
  .get(taskIdValidation, validateRequest, getTask)
  .patch(updateTaskValidation, validateRequest, updateTask)
  .delete(taskIdValidation, validateRequest, deleteTask);

module.exports = router;
