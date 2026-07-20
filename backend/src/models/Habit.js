const mongoose = require('mongoose');

const habitSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Title is required'],
      trim: true,
      index: true,
    },
    streakCount: {
      type: Number,
      default: 0,
    },
    icon: {
      type: String,
      default: '📖',
    },
    completedDates: {
      type: [Date],
      default: [],
    },
    lastCompletedAt: Date,
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
  },
  {
    timestamps: true,
  }
);

habitSchema.index({ userId: 1, title: 1 }, { unique: true });

module.exports = mongoose.model('Habit', habitSchema);
