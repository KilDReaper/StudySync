const StudySession = require('../models/StudySession');
const Task = require('../models/Task');
const Assignment = require('../models/Assignment');
const User = require('../models/User');
const catchAsync = require('../utils/catchAsync');

const getDateRange = (days) => {
  const end = new Date();
  const start = new Date();
  start.setDate(end.getDate() - (days - 1));
  start.setHours(0, 0, 0, 0);
  end.setHours(23, 59, 59, 999);
  return { start, end };
};

const aggregateStudyStats = async (userId, days) => {
  const { start, end } = getDateRange(days);
  return StudySession.aggregate([
    {
      $match: {
        userId,
        status: 'completed',
        completedAt: { $gte: start, $lte: end },
      },
    },
    {
      $addFields: {
        durationHours: {
          $divide: [{ $subtract: ['$endTime', '$startTime'] }, 1000 * 60 * 60],
        },
      },
    },
    {
      $group: {
        _id: {
          $dateToString: {
            format: '%Y-%m-%d',
            date: '$completedAt',
          },
        },
        studyHours: { $sum: '$durationHours' },
        sessions: { $sum: 1 },
      },
    },
    { $sort: { _id: 1 } },
  ]);
};

const getDashboardAnalytics = catchAsync(async (req, res) => {
  const userId = req.user._id;
  const user = await User.findById(userId).select('studyStreak totalStudyHours');

  const [completedTasks, pendingTasks, upcomingAssignments, weeklyStudyStats, monthlyStudyStats] = await Promise.all([
    Task.countDocuments({ userId, status: 'completed' }),
    Task.countDocuments({ userId, status: { $ne: 'completed' } }),
    Assignment.find({ userId, deadline: { $gte: new Date() } }).sort({ deadline: 1 }).limit(5),
    aggregateStudyStats(userId, 7),
    aggregateStudyStats(userId, 30),
  ]);

  const totalStudyHours = user?.totalStudyHours || 0;
  const currentStreak = user?.studyStreak || 0;

  res.status(200).json({
    status: 'success',
    data: {
      totalStudyHours,
      currentStreak,
      completedTasks,
      pendingTasks,
      upcomingAssignments,
      weeklyStudyStatistics: weeklyStudyStats,
      monthlyStudyStatistics: monthlyStudyStats,
    },
  });
});

module.exports = {
  getDashboardAnalytics,
};
