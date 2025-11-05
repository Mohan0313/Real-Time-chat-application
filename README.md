# Real-Time Chat Application

A fully featured, customizable real‑time chat application that supports public channels, private messaging, typing indicators, presence, message history, and more. Built to be easy to run locally, extend, and deploy to production.

> NOTE: This README is written as a complete, ready-to-use template. Adjust any placeholders (technology names, commands, environment variables, endpoints, or examples) to match the actual implementation in this repository.

---

## Table of contents

- [Demo](#demo)
- [Features](#features)
- [Architecture & Tech stack](#architecture--tech-stack)
- [Quick start (development)](#quick-start-development)
  - [Prerequisites](#prerequisites)
  - [Environment variables](#environment-variables)
  - [Install](#install)
  - [Running the app](#running-the-app)
- [Docker / Production](#docker--production)
- [API & WebSocket reference](#api--websocket-reference)
  - [REST endpoints (examples)](#rest-endpoints-examples)
  - [WebSocket events (examples)](#websocket-events-examples)
- [Data model / Schema](#data-model--schema)
- [Authentication & Security](#authentication--security)
- [Testing](#testing)
- [Linting & Formatting](#linting--formatting)
- [CI / CD](#ci--cd)
- [Troubleshooting & FAQ](#troubleshooting--faq)
- [Contributing](#contributing)
- [License](#license)
- [Contact / Credits](#contact--credits)

---

## Demo

- Live demo: (add your demo URL here)
- Example user accounts:
  - user: `alice@example.com` / password: `password`
  - user: `bob@example.com` / password: `password`

(If you don't have a demo, remove the section or provide instructions to run locally.)

---

## Features

- Real‑time messaging using WebSockets
- Public channels / rooms
- Direct (private) messages between users
- Message history and pagination
- Message delivery/read receipts (optional)
- Typing indicators and presence (online/offline)
- User profile (avatar, display name, status)
- Simple role/permission model for rooms (admin/moderator)
- Scalable socket connection handling (namespace/rooms)
- Optional media/file attachments
- JWT-based authentication for APIs and socket authorization

---

## Architecture & Tech stack

This is an example stack — update to reflect your repository's actual stack.

- Backend
  - Node.js + Express (or Fastify)
  - Socket.IO (or native WebSocket / ws)
  - Database: MongoDB (Mongoose) or PostgreSQL (Prisma/TypeORM)
  - Authentication: JWT (access + refresh tokens)
- Frontend
  - React (Create React App / Vite) or Next.js
  - Socket.IO client or WebSocket native client
- Dev & Ops
  - Docker, docker-compose
  - Nginx (optional reverse proxy)
  - CI: GitHub Actions

---

## Quick start (development)

Below are example instructions for a typical Node.js + React project. Adapt the commands to match your repository.

### Prerequisites

- Node.js 18+ (or the version required by the project)
- npm 8+ or yarn 1/2
- MongoDB or PostgreSQL (or use the provided Docker compose)
- Git

### Environment variables

Create a `.env` file in the root (or `server/.env` and `client/.env`) with values like:

```
# Server
PORT=4000
NODE_ENV=development
JWT_SECRET=replace_with_strong_secret
JWT_EXPIRES_IN=1d
REFRESH_TOKEN_SECRET=replace_with_refresh_secret
MONGO_URI=mongodb://localhost:27017/chatapp
# or for Postgres
# DATABASE_URL=postgresql://user:pass@localhost:5432/chatapp

# Optional (for file uploads / mail)
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_S3_BUCKET=
SMTP_HOST=
SMTP_PORT=
SMTP_USER=
SMTP_PASS=
```

> Keep secrets out of source control. Use a secrets manager in production.

### Install

Clone and install dependencies:

```bash
git clone https://github.com/Mohan0313/Real-Time-chat-application.git
cd Real-Time-chat-application

# If monorepo with client/server folders:
# cd server && npm install
# cd ../client && npm install

# Example single-repo:
npm install
```

### Running the app (development)

Start the backend server:

```bash
# In project root or server folder
npm run dev
# or
node ./server/index.js
```

Start the frontend:

```bash
# In client folder
npm start
# or
npm run dev
```

Open http://localhost:3000 (or the port the frontend uses) and test chat functionality.

---

## Docker / Production

Example docker-compose (adjust to your actual Dockerfiles):

```yaml
version: "3.8"
services:
  app:
    build: .
    env_file: .env
    ports:
      - "4000:4000"
    depends_on:
      - mongo
  mongo:
    image: mongo:6
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db

volumes:
  mongo_data:
```

Build & run:

```bash
docker-compose up --build
```

For production, put Nginx or a cloud load balancer in front, enable TLS (Let's Encrypt), and use environment secrets.

---

## API & WebSocket reference

The repository likely has code exposing REST APIs and WebSocket events. Below is a comprehensive example reference — update to exactly reflect your implementation.

### REST endpoints (examples)

- POST /api/auth/register
  - Body: { name, email, password }
  - Response: user object, tokens
- POST /api/auth/login
  - Body: { email, password }
  - Response: accessToken, refreshToken
- POST /api/auth/refresh
  - Body: { refreshToken }
  - Response: new accessToken
- GET /api/users/me
  - Auth: Bearer token
  - Returns current user profile
- GET /api/rooms
  - Returns list of public rooms
- POST /api/rooms
  - Create new room
- GET /api/rooms/:roomId/messages?limit=50&before=<messageId|timestamp>
  - Get message history (pagination)

### WebSocket events (examples)

Connect/Authorize:
- Client connects to socket server and sends authentication token (e.g., in query param or initial `authenticate` event).
- Server validates token and attaches user to socket.

Common events:
- connect / disconnect
- authenticate (client -> server): { token }
  - server replies: authenticated / error
- join_room (client -> server): { roomId }
  - server joins socket to room and emits `user_joined`
- leave_room (client -> server): { roomId }
  - server leaves room and emits `user_left`
- message (client -> server): { roomId, text, attachments?, tempId? }
  - server persists message and emits to room: `message` with messageId, sender, timestamp
- private_message (client -> server): { toUserId, text }
  - server delivers to recipient if online and stores message
- typing (client -> server): { roomId }
  - server emits `typing` to room
- stop_typing (client -> server): { roomId }
  - server emits `stop_typing` to room
- message_ack (client -> server): { messageId }
  - server updates delivery/read status

Server emitted events:
- message (server -> clients in room): { id, text, sender, ts, edited, deleted }
- message_updated
- message_deleted
- user_presence (server -> client): { userId, status } (online/offline)
- room_users (server -> client): { roomId, users[] }

Design notes:
- Use ACK callbacks to confirm persistence & delivery (Socket.IO supports acknowledgements).
- Consider sequence numbers or timestamps to order messages.
- For scalability, use a shared message broker (Redis adapter for Socket.IO) when running multiple instances.

---

## Data model / Schema

Example schema sketches:

User
- _id
- name
- email (unique)
- passwordHash
- avatarUrl
- status (online/away/offline)
- lastSeen
- roles: [roomId -> role] (optional)

Room
- _id
- name
- isPrivate (boolean)
- members: [userId]
- createdBy
- createdAt

Message
- _id
- roomId (nullable for DMs)
- fromUserId
- toUserId (for private messages)
- text
- attachments: [{ url, mimeType }]
- reactions: [{ userId, emoji }]
- readBy: [userId]
- createdAt
- editedAt
- deletedAt

Adjust indexes for fast queries:
- messages: index on (roomId, createdAt) for efficient history fetches
- users: index on email
- rooms: index on isPrivate

---

## Authentication & Security

- Use short-lived JWTs for the socket and REST APIs; protect refresh tokens carefully.
- Always authenticate/authorize socket connections. For Socket.IO, validate token on connection handshake.
- Sanitize and validate messages to prevent XSS.
- Limit attachment sizes and validate mime types.
- Rate-limit endpoints and socket events to prevent spam/DoS.
- Use HTTPS/TLS in production and secure cookie flags if storing tokens in cookies.
- Apply CORS policy for allowed origins.

---

## Testing

- Unit tests: Add tests for core functions (message persistence, auth, utilities).
- Integration tests: Test REST endpoints and socket flows (connect, send message, join room).
- Tools: Jest, Supertest (HTTP), Socket.IO client for integration testing.
- Example commands:
  - npm test
  - npm run test:watch

---

## Linting & Formatting

- ESLint with project rules
- Prettier for consistent formatting
- Example commands:
  - npm run lint
  - npm run format

Configure pre-commit hooks (husky + lint-staged) to run linting and tests before pushes.

---

## CI / CD

- Use GitHub Actions to run lint, tests, and build on pull requests.
- Example checks:
  - nodejs.yml: installs dependencies, runs tests and lint
  - deploy.yml: build and push Docker image, deploy to cloud provider

---

## Troubleshooting & FAQ

Q: Socket doesn't connect in production
- Check CORS and allowed origins on server
- Ensure the correct socket endpoint (ws/wss) is used
- Confirm TLS is correctly set up for secure websockets (wss)

Q: Messages are not persisting
- Confirm database connection string (`MONGO_URI` / `DATABASE_URL`)
- Check server logs for DB errors

Q: Typing indicator isn't reliable
- Ensure client emits `stop_typing` on blur/unfocus and uses debounce to avoid flooding

If you see errors, check logs (server and client), enable verbose logging in dev, and reproduce the issue locally.

---

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Write tests for new features or bugfixes
4. Ensure linting and tests pass
5. Open a pull request with a clear description of changes

Add a CONTRIBUTING.md in the repo for detailed guidelines.

---

## Suggested roadmap (ideas)

- Message reactions & editing UI
- Read receipts per message
- Media uploads with resumable upload (tus)
- Message encryption (E2EE) for private messages
- Presence federations or cross-instance messaging
- Mobile app (React Native or native clients)

---

## License

This project is licensed under the MIT License — see the LICENSE file for details.

---

## Contact / Credits

- Author: Mohan0313 (https://github.com/Mohan0313)
- Contributors: (list contributors)
- Inspired by many open-source chat projects and tutorials

---

If you'd like, I can:
- Convert this template into a polished README tailored exactly to the code in your repository (I can inspect files to auto-fill tech stack, scripts, and real endpoints).
- Generate additional helper files (CONTRIBUTING.md, .env.example, docker-compose.yml) and open a PR with them.

Which would you prefer next?

## 📸 Screenshot
<img width="1919" height="859" alt="Screenshot 2025-06-27 133150" src="https://github.com/user-attachments/assets/e0955dd2-1209-4faf-acf3-0387d4185399" />
