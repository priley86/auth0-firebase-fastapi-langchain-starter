# Setup Guide

This guide will walk you through setting up the Auth0 + Firebase + FastAPI + LangChain Starter template.

## Prerequisites

Before you begin, make sure you have:

1. **Auth0 Account**: Sign up at [auth0.com](https://auth0.com/)
2. **Google AI API Key**: Get one at [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey) for Gemini
3. **Firebase Studio Account** (optional): For cloud development at [idx.google.com](https://idx.google.com/)

> **Note**: This template uses Google Gemini by default. The API key is set via `OPENAI_API_KEY` environment variable as LangChain uses OpenAI-compatible interfaces. To use OpenAI instead, simply change the model name in `backend/app/agents/assistant0.py` to an OpenAI model (e.g., `gpt-4o-mini`).

## Auth0 Setup

### 1. Create an Auth0 Application

1. Log in to your [Auth0 Dashboard](https://manage.auth0.com/)
2. Navigate to **Applications** > **Applications**
3. Click **Create Application**
4. Choose **Regular Web Applications**
5. Give it a name (e.g., "AI Assistant")
6. Click **Create**

### 2. Configure Application Settings

In your application settings:

#### Application URIs

- **Allowed Callback URLs**: 
  ```
  http://localhost:5173/callback
  ```
  
- **Allowed Logout URLs**:
  ```
  http://localhost:5173
  ```
  
- **Allowed Web Origins**:
  ```
  http://localhost:5173
  ```

For Firebase Studio/IDX, you'll also need to add:
- **Allowed Callback URLs**: 
  ```
  https://5173-YOUR-WORKSPACE-ID.idx.google.com/callback
  ```
- **Allowed Logout URLs**:
  ```
  https://5173-YOUR-WORKSPACE-ID.idx.google.com
  ```
- **Allowed Web Origins**:
  ```
  https://5173-YOUR-WORKSPACE-ID.idx.google.com
  ```

#### Save Your Credentials

Note down these values (you'll need them for environment variables):
- **Domain** (e.g., `your-tenant.auth0.com`)
- **Client ID**
- **Client Secret**

### 3. Generate a Secret Key

Generate a random secret key for session management:

```bash
openssl rand -hex 32
```

Or use Python:

```bash
python -c "import secrets; print(secrets.token_hex(32))"
```

## Environment Configuration

### Backend Configuration

1. Navigate to the `backend` directory
2. Copy the example env file:
   ```bash
   cp .env.example .env
   ```
3. Edit `.env` with your credentials:

```env
# Auth0 Configuration
AUTH0_DOMAIN=your-tenant.auth0.com
AUTH0_CLIENT_ID=your-client-id
AUTH0_CLIENT_SECRET=your-client-secret
AUTH0_SECRET=your-generated-secret-key

# Google AI API (for Gemini)
# Get your key at: https://aistudio.google.com/app/apikey
OPENAI_API_KEY=your-google-ai-api-key

# Application URLs
APP_BASE_URL=http://localhost:8000
FRONTEND_HOST=http://localhost:5173

# LangGraph Configuration
LANGGRAPH_API_URL=http://localhost:54367
LANGGRAPH_API_KEY=

# CORS Origins (comma-separated)
BACKEND_CORS_ORIGINS=http://localhost:8000,http://localhost:5173
```

### Frontend Configuration

1. Navigate to the `frontend` directory
2. Copy the example env file:
   ```bash
   cp .env.example .env
   ```
3. Edit `.env` with your credentials:

```env
# Auth0 Configuration
VITE_AUTH0_DOMAIN=your-tenant.auth0.com
VITE_AUTH0_CLIENT_ID=your-client-id

# API URL
VITE_API_URL=http://localhost:8000
```

## Running the Application

### Option 1: Using Firebase Studio (Project IDX)

1. Click the "Open in IDX" button in the README
2. Wait for the workspace to initialize
3. Configure your `.env` files as described above
4. The servers will start automatically!

### Option 2: Local Development

#### Terminal 1: Backend API

```bash
cd backend
uv sync
source .venv/bin/activate
fastapi dev app/main.py
```

The backend will run on `http://localhost:8000`

#### Terminal 2: LangGraph Server

```bash
cd backend
source .venv/bin/activate
langgraph dev --port 54367 --no-browser
```

The LangGraph server will run on `http://localhost:54367`

#### Terminal 3: Frontend

```bash
cd frontend
npm install
npm run dev
```

The frontend will run on `http://localhost:5173`

## Verifying the Setup

1. Open your browser to `http://localhost:5173`
2. You should be redirected to Auth0 login
3. After logging in, you should see the chat interface
4. Try sending a message to the AI assistant

## Troubleshooting

### Auth0 Errors

- **"Callback URL mismatch"**: Make sure your callback URLs are configured correctly in Auth0
- **"Client authentication failed"**: Double-check your Client ID and Client Secret

### Backend Errors

- **"Module not found"**: Run `uv sync` again in the backend directory
- **"API error"**: Verify your Google AI API key is correct and enabled. Get one at [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)

### Frontend Errors

- **"Cannot connect to backend"**: Make sure the backend server is running
- **"Auth0 configuration error"**: Verify your Auth0 domain and client ID in `.env`

### LangGraph Errors

- **"Cannot connect to LangGraph"**: Make sure the LangGraph server is running on port 54367
- **"Agent not found"**: Verify `langgraph.json` is configured correctly

## Next Steps

Once everything is working:

1. **Customize the Agent**: Edit `backend/app/agents/assistant0.py` to add new capabilities
2. **Add Tools**: Integrate external APIs and services
3. **Improve the UI**: Customize the React components in `frontend/src/`
4. **Deploy**: Deploy to your preferred hosting platform

## Getting Help

- [Auth0 Documentation](https://auth0.com/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [Firebase Studio Documentation](https://firebase.google.com/docs/studio)
- [GitHub Issues](https://github.com/priley86/auth0-firebase-fastapi-langchain-starter/issues)
