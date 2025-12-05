# Auth0 + Firebase + FastAPI + LangChain Starter

An AI personal assistant template secured with Auth0, built on Firebase Studio (Project IDX), using FastAPI, LangGraph, and Vite/React.

[![Open in IDX](https://cdn.idx.dev/btn/open_dark_32@2x.png)](https://idx.google.com/new?template=https://github.com/priley86/auth0-firebase-fastapi-langchain-starter)

## About

This template provides a full-stack AI application starter with:

- **[Auth0](https://auth0.com/)** for authentication and authorization
- **[FastAPI](https://fastapi.tiangolo.com/)** for the backend API
- **[LangChain](https://python.langchain.com/)** and **[LangGraph](https://langchain-ai.github.io/langgraph/)** for building AI agents
- **Flexible LLM support** - easily swap between **[OpenAI](https://openai.com/)** and **[Google Gemini](https://ai.google.dev/)** models
- **[Vite](https://vite.dev/)** + **[React](https://react.dev/)** for the frontend
- **[Firebase Studio (Project IDX)](https://idx.google.com/)** for the development environment

## Features

- 🔐 **Secure Authentication** with Auth0 FastAPI SDK
- 🤖 **AI-Powered Chat** using LangGraph agents (supports OpenAI & Google Gemini)
- 🔌 **Third-Party API Integration** via Auth0 AI SDK (Token Vault)
- 🚀 **Fast Development** with hot reload on frontend and backend
- 📦 **Modern Stack** with TypeScript, Python 3.13+, React 19, and Tailwind CSS 4
- 🎨 **Beautiful UI** with shadcn/ui components
- 🔧 **Easy Setup** with Firebase Studio (Project IDX)

## Architecture

The project is divided into three main parts:

```
.
├── backend/           # FastAPI backend
│   ├── app/
│   │   ├── agents/    # LangGraph agent definitions
│   │   ├── api/       # API routes
│   │   ├── core/      # Core configurations
│   │   └── main.py    # FastAPI application
│   ├── pyproject.toml
│   └── .env.example
├── frontend/          # Vite + React frontend
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── lib/
│   │   └── main.tsx
│   ├── package.json
│   └── .env.example
└── .idx/
    └── dev.nix        # Firebase Studio configuration
```

## Getting Started

### Prerequisites

- An [Auth0](https://auth0.com/) account with a Web Application configured
- An LLM API key:
  - **[OpenAI API key](https://platform.openai.com/api-keys)** for GPT models, OR
  - **[Google AI API key](https://aistudio.google.com/app/apikey)** for Gemini models
- A [Firebase Studio (Project IDX)](https://idx.google.com/) workspace (or local development environment)
- (Optional) Google Calendar API credentials if using the calendar tool

> **Note**: This template supports both OpenAI and Google Gemini models. The default configuration uses OpenAI's `gpt-4o-mini`. To switch to Google Gemini models, see `GEMINI.md` for detailed instructions.

### Quick Start with Firebase Studio (Project IDX)

1. Click the "Open in IDX" button above
2. Wait for the workspace to initialize (dependencies will be installed automatically)
3. Configure your environment variables (see below)
4. The servers will start automatically!

> **⚠️ Important for Firebase Studio users**: The embedded "Web" preview window may show authentication errors due to third-party cookie blocking. **Always use the "Preview" button or "Open in new tab" button** (↗️) to open the application in a full browser tab where authentication will work correctly.

### Environment Variables

#### Backend (`backend/.env`)

Copy `backend/.env.example` to `backend/.env` and configure:

```env
# Auth0 Configuration
AUTH0_DOMAIN=your-tenant.auth0.com
AUTH0_CLIENT_ID=your-client-id
AUTH0_CLIENT_SECRET=your-client-secret
AUTH0_SECRET=your-secret-key

# LLM API Key (choose one based on your provider)
# For OpenAI: Get your key at https://platform.openai.com/api-keys
# For Gemini: Get your key at https://aistudio.google.com/app/apikey
# (see GEMINI.md for switching between providers)
OPENAI_API_KEY=your-api-key

# Application URLs
APP_BASE_URL=http://localhost:8000
FRONTEND_HOST=http://localhost:5173

# LangGraph (optional, defaults are set)
LANGGRAPH_API_URL=http://localhost:54367
LANGGRAPH_API_KEY=

# CORS
BACKEND_CORS_ORIGINS=http://localhost:8000,http://localhost:5173
```

#### Frontend (`frontend/.env`)

Copy `frontend/.env.example` to `frontend/.env` and configure:

```env
# API URL
VITE_API_URL=http://localhost:8000
```

### Local Development (without Firebase Studio)

If you want to run this locally without Firebase Studio:

#### 1. Clone the repository

```bash
git clone https://github.com/priley86/auth0-firebase-fastapi-langchain-starter.git
cd auth0-firebase-fastapi-langchain-starter
```

#### 2. Setup the backend

```bash
cd backend
uv sync
cp .env.example .env
# Edit .env with your credentials
```

Run the FastAPI server:

```bash
source .venv/bin/activate
fastapi dev app/main.py
```

#### 3. Start the LangGraph server

In a new terminal:

```bash
cd backend
source .venv/bin/activate
langgraph dev --port 54367 --no-browser
```

#### 4. Setup the frontend

In a new terminal:

```bash
cd frontend
npm install
cp .env.example .env
# Edit .env with your credentials
npm run dev
```

The frontend will be available at `http://localhost:5173`

## Auth0 Setup

1. Create a new Auth0 application (Regular Web Application)
2. Configure the following settings:
   - **Allowed Callback URLs**: `http://localhost:5173/callback`
   - **Allowed Logout URLs**: `http://localhost:5173`
   - **Allowed Web Origins**: `http://localhost:5173`
3. Copy your Domain, Client ID, and Client Secret to your `.env` files

## Project Structure

### Backend

- `app/agents/` - LangGraph agent definitions and workflows
- `app/api/routes/` - FastAPI route handlers
- `app/core/` - Configuration, authentication, and shared utilities
- `app/main.py` - FastAPI application entry point

### Frontend

- `src/components/` - Reusable React components
- `src/pages/` - Page components
- `src/lib/` - Utility functions and API clients
- `src/main.tsx` - React application entry point

## Customization

### Modifying the AI Agent

The LangGraph agent is defined in `backend/app/agents/assistant0.py`. You can:

- Change the system prompt in the `get_prompt()` function
- Add new tools in `backend/app/agents/tools/`
- Switch between LLM providers (OpenAI/Gemini) and models (see GEMINI.md)
- Modify the agent's reasoning approach (ReAct, Planning, etc.)

### Styling the Frontend

The frontend uses Tailwind CSS. You can customize:

- `frontend/tailwind.config.js` - Tailwind configuration
- `frontend/src/components/` - Component styles
- Theme colors and typography

## Deployment

This template is optimized for Firebase Studio development, but can be deployed to:

- **Backend**: Google Cloud Run, AWS Lambda, or any container platform
- **Frontend**: Vercel, Netlify, or Firebase Hosting
- **LangGraph**: LangGraph Cloud or self-hosted

## Learn More

- [Auth0 Documentation](https://auth0.com/docs)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [LangChain Documentation](https://python.langchain.com/)
- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [Firebase Studio Documentation](https://firebase.google.com/docs/studio)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Credits

This template is inspired by the [Auth0 AI Samples](https://github.com/auth0-samples/auth0-ai-samples) and adapted for Firebase Studio (Project IDX).

## Support

For issues and questions:
- [GitHub Issues](https://github.com/priley86/auth0-firebase-fastapi-langchain-starter/issues)
- [Auth0 Community](https://community.auth0.com/)
- [LangChain Discord](https://discord.gg/langchain)
