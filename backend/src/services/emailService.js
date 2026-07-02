const nodemailer = require('nodemailer');

const createTransporter = () =>
  nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: Number(process.env.SMTP_PORT || 587),
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });

const sendEmail = async ({ to, subject, text, html }) => {
  if (!process.env.SMTP_HOST || !process.env.SMTP_USER || !process.env.SMTP_PASS) {
    return null;
  }

  const transporter = createTransporter();
  return transporter.sendMail({
    from: process.env.SMTP_FROM || 'StudySync <no-reply@studysync.com>',
    to,
    subject,
    text,
    html,
  });
};

const sendPasswordResetEmail = async ({ to, resetUrl, name }) =>
  sendEmail({
    to,
    subject: 'StudySync password reset',
    text: `Hi ${name}, use this link to reset your password: ${resetUrl}`,
    html: `<p>Hi ${name},</p><p>Use this link to reset your password:</p><p><a href="${resetUrl}">${resetUrl}</a></p>`,
  });

const sendNotificationEmail = async ({ to, subject, message }) =>
  sendEmail({
    to,
    subject,
    text: message,
    html: `<p>${message}</p>`,
  });

module.exports = {
  sendEmail,
  sendNotificationEmail,
  sendPasswordResetEmail,
};
