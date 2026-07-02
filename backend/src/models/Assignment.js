const mongoose = require('mongoose');

const fileSchema = new mongoose.Schema(
  {
    url: String,
    filename: String,
    mimetype: String,
    size: Number,
  },
  { _id: false }
);

const assignmentSchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Title is required'],
      trim: true,
      index: true,
    },
    subject: {
      type: String,
      required: [true, 'Subject is required'],
      trim: true,
      index: true,
    },
    deadline: {
      type: Date,
      required: [true, 'Deadline is required'],
      index: true,
    },
    progress: {
      type: Number,
      default: 0,
      min: 0,
      max: 100,
    },
    fileAttachment: fileSchema,
    submissionStatus: {
      type: String,
      enum: ['not-submitted', 'submitted', 'graded'],
      default: 'not-submitted',
      index: true,
    },
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

assignmentSchema.index({ userId: 1, deadline: 1 });

module.exports = mongoose.model('Assignment', assignmentSchema);
