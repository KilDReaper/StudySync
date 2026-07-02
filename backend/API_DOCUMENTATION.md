# StudySync API Documentation

Base URL: `/api/v1`

Authentication uses JWT access tokens and refresh tokens. Refresh tokens are stored in HTTP-only cookies and can also be sent in the request body for API clients.

## Common Status Codes

- `200 OK` - Successful fetch/update/delete
- `201 Created` - Resource created
- `400 Bad Request` - Validation or input error
- `401 Unauthorized` - Missing or invalid token
- `403 Forbidden` - Role/permission denied
- `404 Not Found` - Resource not found
- `409 Conflict` - Duplicate or conflicting resource
- `500 Internal Server Error` - Unexpected server error

## Auth Endpoints

### Register
`POST /auth/register`

Request body:
```json
{
  "fullName": "John Doe",
  "email": "john@example.com",
  "password": "Password123!"
}
```

Response:
```json
{
  "status": "success",
  "message": "User registered successfully",
  "accessToken": "jwt-access-token",
  "data": {
    "user": {
      "_id": "66f...",
      "fullName": "John Doe",
      "email": "john@example.com",
      "role": "student",
      "studyStreak": 0,
      "totalStudyHours": 0,
      "createdAt": "2026-06-14T10:00:00.000Z",
      "updatedAt": "2026-06-14T10:00:00.000Z"
    }
  }
}
```

### Login
`POST /auth/login`

Request body:
```json
{
  "email": "john@example.com",
  "password": "Password123!"
}
```

Response: `200 OK`

### Logout
`POST /auth/logout`

Response:
```json
{ "status": "success", "message": "Logged out successfully" }
```

### Refresh Token
`POST /auth/refresh-token`

Request body:
```json
{ "refreshToken": "jwt-refresh-token" }
```

Response: `200 OK`

### Forgot Password
`POST /auth/forgot-password`

Request body:
```json
{ "email": "john@example.com" }
```

Response:
```json
{ "status": "success", "message": "Password reset instructions sent" }
```

### Reset Password
`PATCH /auth/reset-password/:token`

Request body:
```json
{
  "email": "john@example.com",
  "newPassword": "NewPassword123!"
}
```

### Get Current User
`GET /auth/me`

Response: `200 OK`

### Update Profile
`PATCH /auth/update-profile`

Multipart form-data fields:
- `fullName`
- `email`
- `profilePicture` file

### Change Password
`PATCH /auth/change-password`

Request body:
```json
{
  "currentPassword": "Password123!",
  "newPassword": "NewPassword123!"
}
```

## Study Sessions

### Create Session
`POST /study-sessions`

```json
{
  "title": "Math Revision",
  "description": "Algebra and calculus",
  "subject": "Mathematics",
  "startTime": "2026-06-14T14:00:00.000Z",
  "endTime": "2026-06-14T16:00:00.000Z",
  "priority": "high"
}
```

### List Sessions
`GET /study-sessions?page=1&limit=10&status=pending&priority=high&subject=Math`

### Get Single Session
`GET /study-sessions/:id`

### Update Session
`PATCH /study-sessions/:id`

### Mark Complete
`PATCH /study-sessions/:id/complete`

### Delete Session
`DELETE /study-sessions/:id`

## Tasks

### Create Task
`POST /tasks`

```json
{
  "title": "Read chapter 3",
  "description": "Focus on problem sets",
  "dueDate": "2026-06-16T00:00:00.000Z",
  "priority": "medium",
  "status": "pending"
}
```

### List Tasks
`GET /tasks?status=pending&priority=high&search=chapter&page=1&limit=10`

### Get Task
`GET /tasks/:id`

### Update Task
`PATCH /tasks/:id`

### Delete Task
`DELETE /tasks/:id`

## Assignments

### Create Assignment
`POST /assignments`

Multipart form-data fields:
- `title`
- `subject`
- `deadline`
- `progress`
- `fileAttachment` file

### List Assignments
`GET /assignments?submissionStatus=submitted&subject=Science`

### Get Assignment
`GET /assignments/:id`

### Update Assignment
`PATCH /assignments/:id`

### Update Submission Status
`PATCH /assignments/:id/status`

Request body:
```json
{ "submissionStatus": "submitted" }
```

### Delete Assignment
`DELETE /assignments/:id`

## Goals

### Create Goal
`POST /goals`

```json
{
  "title": "Complete 50 study hours",
  "targetHours": 50,
  "completedHours": 10,
  "deadline": "2026-07-01T00:00:00.000Z"
}
```

### List Goals
`GET /goals`

### Update Goal
`PATCH /goals/:id`

### Update Goal Progress
`PATCH /goals/:id/progress`

```json
{ "completedHours": 35 }
```

### Delete Goal
`DELETE /goals/:id`

## Habits

### Create Habit
`POST /habits`

```json
{ "title": "Morning reading" }
```

### List Habits
`GET /habits`

### Mark Habit Complete
`PATCH /habits/:id/complete`

### View Streak
`GET /habits/:id/streak`

### Delete Habit
`DELETE /habits/:id`

## Notifications

### List Notifications
`GET /notifications`

### Mark Notification Read
`PATCH /notifications/:id/read`

### Mark All Read
`PATCH /notifications/read-all`

### Delete Notification
`DELETE /notifications/:id`

## Dashboard

### Analytics
`GET /dashboard/analytics`

Response example:
```json
{
  "status": "success",
  "data": {
    "totalStudyHours": 18.5,
    "currentStreak": 4,
    "completedTasks": 12,
    "pendingTasks": 5,
    "upcomingAssignments": [],
    "weeklyStudyStatistics": [],
    "monthlyStudyStatistics": []
  }
}
```

## Admin

Admin routes require an authenticated user with the `admin` role, except report submission.

### Submit Report
`POST /admin/reports`

```json
{
  "contentType": "task",
  "contentId": "66f...",
  "reason": "Inappropriate content"
}
```

### View Users
`GET /admin/users`

### Delete User
`DELETE /admin/users/:id`

### Platform Statistics
`GET /admin/stats`

### View Reports
`GET /admin/reports`

### Update Report
`PATCH /admin/reports/:id`

```json
{
  "status": "reviewed",
  "notes": "Reviewed and resolved"
}
```

## Environment Variables

See `.env.example` for all required values.
