# StudySync Backend

Production-ready Node.js + Express backend for a study management platform.

## Setup

1. Install dependencies.
2. Copy `.env.example` to `.env` and fill in the values.
3. Start MongoDB locally or point `MONGODB_URI` to your cluster.
4. Run `npm run dev` for development or `npm start` for production.

## Included

- JWT authentication with access and refresh tokens
- Role-based authorization
- Study sessions, tasks, assignments, goals, habits, notifications
- Dashboard analytics and admin reporting/stats
- Centralized validation and error handling
- Multer file uploads to `src/uploads`

See [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for the endpoint reference.
