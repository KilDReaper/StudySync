const mongoose = require('mongoose');

const reportSchema = new mongoose.Schema(
  {
    contentType: {
      type: String,
      required: [true, 'Content type is required'],
      enum: ['task', 'session', 'habit', 'assignment'],
    },
    contentId: {
      type: mongoose.Schema.Types.ObjectId,
      required: [true, 'Content ID is required'],
    },
    reason: {
      type: String,
      required: [true, 'Reason is required'],
      trim: true,
    },
    reporter: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true,
    },
    status: {
      type: String,
      enum: ['pending', 'reviewed', 'resolved'],
      default: 'pending',
    },
    notes: {
      type: String,
      trim: true,
      default: '',
    },
    reviewedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Report', reportSchema);
