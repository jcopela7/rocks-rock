# jonrocks

A climbing app built for climbers by climbers. Think Strava for rock climbing.

## Project Structure

This is a monorepo containing:

- **`api/`** — Node.js + Fastify + Drizzle ORM backend API
- **`web/`** — React + TypeScript + Vite web frontend
- **`ios/`** — SwiftUI iOS mobile app

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** (v18 or higher recommended)
- **npm** (comes with Node.js)
- **PostgreSQL** (v12 or higher)
- **Xcode** (for iOS development, macOS only)

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd jonrocks
```

### 2. Install Dependencies

Install dependencies for all workspaces:

```bash
npm install
```

This will install dependencies for the root workspace, `api/`, and `web/`.

### 3. Database Setup

1. **Create a PostgreSQL database:**

```bash
createdb jonrocks
# Or using psql:
# psql -c "CREATE DATABASE jonrocks;"
```

2. **Set up environment variables:**

Create a `.env` file in the `api/` directory:

```bash
cd api
touch .env
```

Add the following to `api/.env`:

```env
DATABASE_URL=postgresql://localhost:5432/jonrocks
PORT=3000

# Auth0 Configuration (optional for local development)
# AUTH0_DOMAIN=your-domain.auth0.com
# AUTH0_AUDIENCE=your-api-audience
```

**Note:** If you're not working on authentication features, you can skip the Auth0 variables. The database migrations will run automatically when you start the server.

### 4. Run the API Server

From the `api/` directory:

```bash
cd api
npm start
```

Or from the root:

```bash
cd api && npm start
```

The server will:
- Run database migrations automatically
- Start on `http://localhost:3000` (or the port specified in `PORT`)
- Print available routes to the console

You can verify it's working by visiting:
- `http://localhost:3000/` — Health check endpoint
- `http://localhost:3000/db/health` — Database health check

### 5. Run the Web Frontend

In a new terminal, from the `web/` directory:

```bash
cd web
npm run dev
```

The web app will start on `http://localhost:5173` (Vite's default port).

### 6. iOS Development

1. Open the Xcode project:

```bash
open ios/jonrocks/jonrocks.xcodeproj
```

2. Configure your development team and signing in Xcode
3. Build and run the app on a simulator or device

**Note:** The iOS app may require additional configuration for API endpoints and authentication. Check the iOS project's configuration files for environment-specific settings.

## Development Workflow

### Formatting Code

Format all TypeScript/TSX files:

```bash
npm run format:tsx
```

Check formatting without making changes:

```bash
npm run format:tsx:check
```

Format Swift files (requires `swift-format`):

```bash
npm run format:swift
```

### Database Migrations

The API server automatically runs migrations on startup. To create a new migration:

```bash
cd api
npx drizzle-kit generate
```

To apply migrations manually:

```bash
npx drizzle-kit migrate
```

### Project Scripts

**Root level:**
- `npm run format:tsx` — Format all TypeScript/TSX files
- `npm run format:tsx:check` — Check formatting
- `npm run format:swift` — Format Swift files

**API (`api/`):**
- `npm start` — Start the development server
- `npm run format` — Format code
- `npm run format:check` — Check formatting

**Web (`web/`):**
- `npm run dev` — Start development server
- `npm run build` — Build for production
- `npm run preview` — Preview production build
- `npm run lint` — Run ESLint
- `npm run format` — Format code

## Environment Variables

### API Server (`api/.env`)

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | Yes | PostgreSQL connection string |
| `PORT` | No | Server port (default: 3000) |
| `AUTH0_DOMAIN` | Optional | Auth0 domain for authentication |
| `AUTH0_AUDIENCE` | Optional | Auth0 API audience identifier |

## API Endpoints

The API runs on `http://localhost:3000` with routes prefixed with `/api/v1`:

- `GET /` — Health check
- `GET /db/health` — Database health check
- `/api/v1/ascents` — Ascent management
- `/api/v1/locations` — Location management
- `/api/v1/routes` — Route management
- `/api/v1/user` — User management

## Troubleshooting

### Database Connection Issues

- Ensure PostgreSQL is running: `pg_isready`
- Verify your `DATABASE_URL` is correct
- Check that the database exists: `psql -l | grep jonrocks`

### Port Already in Use

If port 3000 is already in use, set a different port in `api/.env`:

```env
PORT=3001
```

### Migration Errors

If migrations fail, you may need to reset the database:

```bash
# ⚠️ WARNING: This will delete all data
dropdb jonrocks
createdb jonrocks
```

Then restart the API server to run migrations again.

## Contributing

1. Create a feature branch
2. Make your changes
3. Ensure code is formatted: `npm run format:tsx:check`
4. Test your changes locally
5. Submit a pull request

## License

[Add your license information here]
