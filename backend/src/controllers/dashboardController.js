const Task = require('../models/Task');
const Assignment = require('../models/Assignment');
const StudySession = require('../models/StudySession');
const catchAsync = require('../utils/catchAsync');

const getAnalytics = catchAsync(async (req, res) => {
  const userId = req.user._id;

  const [completedTasks, pendingTasks] = await Promise.all([
    Task.countDocuments({ userId, status: 'completed' }),
    Task.countDocuments({ userId, status: 'pending' }),
  ]);

  const upcomingAssignments = await Assignment.find({
    userId,
    deadline: { $gte: new Date() },
    submissionStatus: 'pending',
  })
    .sort({ deadline: 1 })
    .limit(5);

  const sevenDaysAgo = new Date();
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

  const weeklyStats = await StudySession.aggregate([
    {
      $match: {
        userId,
        completed: true,
        startTime: { $gte: sevenDaysAgo },
      },
    },
    {
      $group: {
        _id: { $dateToString: { format: '%Y-%m-%d', date: '$startTime' } },
        durationMs: {
          $sum: { $subtract: ['$endTime', '$startTime'] },
        },
      },
    },
    {
      $project: {
        _id: 0,
        date: '$_id',
        hours: { $round: [{ $divide: ['$durationMs', 3600000] }, 2] },
      },
    },
    { $sort: { date: 1 } },
  ]);

  const thirtyDaysAgo = new Date();
  thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

  const monthlyStats = await StudySession.aggregate([
    {
      $match: {
        userId,
        completed: true,
        startTime: { $gte: thirtyDaysAgo },
      },
    },
    {
      $group: {
        _id: { $dateToString: { format: '%Y-%m-%d', date: '$startTime' } },
        durationMs: {
          $sum: { $subtract: ['$endTime', '$startTime'] },
        },
      },
    },
    {
      $project: {
        _id: 0,
        date: '$_id',
        hours: { $round: [{ $divide: ['$durationMs', 3600000] }, 2] },
      },
    },
    { $sort: { date: 1 } },
  ]);

  res.status(200).json({
    status: 'success',
    data: {
      totalStudyHours: req.user.totalStudyHours,
      currentStreak: req.user.studyStreak,
      completedTasks,
      pendingTasks,
      upcomingAssignments,
      weeklyStudyStatistics: weeklyStats,
      monthlyStudyStatistics: monthlyStats,
    },
  });
});

module.exports = {
  getAnalytics,
};
