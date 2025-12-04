# Guide for Gemini AI

This document provides context and guidelines for Gemini AI when assisting with improvements to this Firebase Studio template.

## Project Overview

This is a **Firebase Studio (Project IDX) community template** that provides a full-stack AI application starter with:
- **Backend**: FastAPI (Python 3.13+) with Auth0 authentication
- **AI Agent**: LangGraph with **Google Gemini** (via OpenAI-compatible interface)
- **Frontend**: React 19 + Vite + TypeScript
- **Dev Environment**: Firebase Studio with NIX configuration

**Target Users**: Developers who want to quickly spin up secure, AI-powered applications in Firebase Studio.

## Architecture & Key Concepts

### Three-Server Architecture
1. **FastAPI Backend** (port 8000) - Main API server with Auth0 authentication
2. **LangGraph Server** (port 54367) - AI agent runtime
3. **Vite Frontend** (port 5173) - React web application

### Data Flow
```
User → Frontend (Auth0 login)
Frontend → Backend (/api/agent/*) [Authenticated]
Backend → LangGraph Server [With user context]
LangGraph → Gemini (via langchain_openai) [Agent processing]
Gemini → LangGraph → Backend → Frontend [Streaming response]
```

### Firebase Studio Integration
- **NIX Configuration**: `dev.nix` and `idx-template.nix` define the environment
- **Auto-start**: Servers start automatically via `onStart` hooks
- **Environment Variables**: Pre-configured for IDX workspace URLs
- **Template Bootstrap**: `idx-template.nix` sets up new workspaces

## File Structure Reference

```
Root Files (Template Configuration)
├── idx-template.json       → Template metadata for Firebase Studio
├── idx-template.nix        → Bootstrap script for new workspaces
├── dev.nix                 → Master NIX configuration
└── .idx/dev.nix           → Workspace-specific NIX (auto-created)

Backend (Python/FastAPI)
├── app/
│   ├── agents/            → LangGraph agents (START HERE for AI changes)
│   │   ├── assistant0.py  → Main chatbot agent (using Gemini)
│   │   └── tools/         → Agent tools (e.g., Google Calendar)
│   ├── api/routes/        → API endpoints
│   │   ├── chat.py        → LangGraph proxy endpoint
│   │   └── profile.py     → User profile endpoint
│   ├── core/              → Configuration & Auth
│   │   ├── config.py      → Settings from environment
│   │   ├── auth.py        → Auth0 FastAPI SDK routes
│   │   └── auth0_ai.py    → Auth0 AI SDK for third-party APIs
│   └── main.py            → FastAPI app entry point
├── pyproject.toml         → Python dependencies (uv)
├── uv.lock                → Locked dependencies
└── langgraph.json         → LangGraph agent configuration

Frontend (React/TypeScript)
├── src/
│   ├── components/        → UI components
│   │   ├── layout.tsx     → App layout with header, nav, UserButton
│   │   ├── chat-window.tsx → Reusable chat interface (streaming)
│   │   ├── auth0/         → Auth0 components (user-button, etc.)
│   │   ├── auth0-ai/      → TokenVault for OAuth (third-party APIs)
│   │   └── ui/            → shadcn/ui components library
│   ├── lib/               → Shared utilities
│   │   ├── use-auth.ts    → Auth state hook
│   │   ├── api-client.ts  → Axios instance
│   │   └── utils.ts       → Helper functions
│   ├── pages/             → Route pages
│   │   ├── ChatPage.tsx   → Main chat page
│   │   └── ClosePage.tsx  → OAuth popup close handler
│   ├── main.tsx           → React entry point (React Router)
│   └── globals.css        → Global styles (Tailwind)
├── index.html             → HTML entry point
├── vite.config.ts         → Vite configuration
└── tailwind.config.js     → Tailwind CSS configuration
```

## Common Improvement Scenarios

### 1. Current Setup: Gemini via OpenAI-Compatible Interface

**Current Configuration** (Default):
This template uses Gemini through LangChain's `ChatOpenAI` class, which supports Gemini models via OpenAI-compatible interfaces:

```python
# backend/app/agents/assistant0.py
from langchain_openai import ChatOpenAI
llm = ChatOpenAI(model="gemini-2.0-flash-exp")
```

**Advantages**:
- ✅ No additional dependencies needed
- ✅ Uses `OPENAI_API_KEY` environment variable (set to your Google AI API key)
- ✅ Simple to switch between OpenAI and Gemini models
- ✅ Works with existing LangChain tooling

**Switching Models**:
```python
# Use different Gemini models:
llm = ChatOpenAI(model="gemini-2.0-flash-exp")  # Fast, efficient (default)
llm = ChatOpenAI(model="gemini-pro")             # Balanced
llm = ChatOpenAI(model="gemini-pro-vision")      # Multimodal

# Or switch to OpenAI:
llm = ChatOpenAI(model="gpt-4o-mini")            # OpenAI
llm = ChatOpenAI(model="gpt-4o")                 # OpenAI advanced
```

### 2. Alternative: Using Native Gemini SDK (Optional)

If you prefer the native `langchain-google-genai` integration:

**Files to modify**:
1. `backend/app/agents/assistant0.py`:
   ```python
   # Change from:
   from langchain_openai import ChatOpenAI
   llm = ChatOpenAI(model="gemini-2.0-flash-exp")
   
   # To:
   from langchain_google_genai import ChatGoogleGenerativeAI
   llm = ChatGoogleGenerativeAI(model="gemini-pro")
   ```

2. `backend/pyproject.toml`:
   ```toml
   # Add to dependencies:
   "langchain-google-genai>=2.0.0",
   ```

3. `backend/.env.example`:
   ```env
   # Add (keep OPENAI_API_KEY for compatibility):
   GOOGLE_API_KEY=your-google-api-key
   ```

4. `backend/app/core/config.py`:
   ```python
   # Add:
   GOOGLE_API_KEY: str
   ```

**When to use native SDK**:
- Need Gemini-specific features (safety settings, grounding)
- Want explicit control over Gemini parameters
- Building Gemini-only applications

### 3. Adding New Agent Tools

**Location**: `backend/app/agents/tools/` (e.g., `google_calendar.py`)

**Pattern**:
```python
from langchain_core.tools import tool

@tool
def my_custom_tool(query: str) -> str:
    """Tool description for the agent."""
    # Implementation
    return result

# In assistant0.py, import and add to agent:
from app.agents.tools.my_custom_tool import my_custom_tool
tools = [my_custom_tool, google_calendar_tool]
agent = create_react_agent(llm, tools)
```

### 4. Enhancing the Chat UI

**Location**: `frontend/src/pages/ChatPage.tsx`

**Key sections**:
- Message state: `messages` useState array
- Send handler: `sendMessage` function
- UI rendering: JSX at bottom of component
- Styling: Tailwind CSS classes

### 5. Adding New API Routes

1. Create new file: `backend/app/api/routes/your_route.py`
2. Import in: `backend/app/api/api_router.py`
3. Add router: `api_router.include_router(your_router)`

### 6. Modifying Firebase Studio Behavior

**Location**: `dev.nix` or `.idx/dev.nix`

**Key sections**:
- `packages`: NIX packages to install
- `env`: Environment variables for IDX
- `workspace.onCreate`: Runs on workspace creation
- `workspace.onStart`: Runs on workspace (re)start
- `previews`: Web preview configuration

## Important Constraints

### DO NOT modify:
- ❌ `idx-template.json` structure (breaks Firebase Studio integration)
- ❌ `idx-template.nix` unless changing bootstrap logic
- ❌ Authentication flow without understanding Auth0 implications
- ❌ Port numbers (8000, 54367, 5173) without updating all references

### ALWAYS consider:
- ✅ Environment variable changes need updates in multiple `.env.example` files
- ✅ Backend changes may require frontend API client updates
- ✅ New dependencies need to be added to `pyproject.toml` or `package.json`
- ✅ Auth0 configuration changes need documentation updates
- ✅ NIX package additions should specify exact versions when possible

## Testing Guidelines

### Local Testing Workflow
```bash
# Backend
cd backend
uv sync
source .venv/bin/activate
fastapi dev app/main.py

# LangGraph (separate terminal)
cd backend
source .venv/bin/activate
langgraph dev --port 54367

# Frontend (separate terminal)
cd frontend
npm install
npm run dev
```

### Firebase Studio Testing
1. Commit changes to GitHub
2. Test via: `https://idx.google.com/new?template=https://github.com/USER/REPO`
3. Verify `onCreate` and `onStart` hooks work correctly
4. Check all three servers start automatically

## Code Style Preferences

### Python (Backend)
- Use type hints for all function parameters and returns
- Follow PEP 8
- Prefer `async/await` for I/O operations
- Use Pydantic models for data validation
- Document functions with docstrings

### TypeScript (Frontend)
- Use functional components with hooks
- Prefer `const` over `let`
- Use TypeScript interfaces for props
- Follow React best practices
- Use Tailwind CSS for styling (no custom CSS unless necessary)

### NIX (Configuration)
- Comment complex configurations
- Use absolute paths for clarity
- Specify exact package versions when stability is critical

## Common Pitfalls

1. **Forgetting to update environment variables**: Changes to config often need updates in:
   - `backend/.env.example`
   - `frontend/.env.example`
   - `dev.nix` (env section)
   - Documentation files

2. **Breaking the proxy**: The FastAPI → LangGraph proxy in `chat.py` is critical:
   - Maintains authentication context
   - Handles streaming responses
   - Don't modify unless necessary

3. **NIX syntax errors**: NIX is very sensitive to syntax:
   - Missing semicolons
   - Incorrect attribute paths
   - Malformed lists or sets

4. **CORS issues**: Frontend and backend CORS must be aligned:
   - `backend/app/core/config.py` (CORS origins)
   - `frontend/vite.config.ts` (proxy config)

## Gemini-Specific Considerations

### When Adding Gemini Support

1. **Multimodal capabilities**: Gemini supports images/video. Consider adding:
   - File upload in frontend
   - Multimodal message handling in backend
   - Image processing in agent

2. **Context window**: Gemini has large context windows. Consider:
   - Sending more conversation history
   - Including relevant documents in context

3. **Function calling**: Gemini's function calling works well with LangChain tools:
   - Use `bind_tools()` method
   - Define clear tool descriptions

4. **Safety settings**: Gemini has configurable safety settings:
   - Add safety configuration in agent initialization
   - Document safety thresholds in README

### Performance Optimization for Gemini

- **Streaming**: Already implemented, works with Gemini
- **Caching**: Consider adding prompt caching for repeated contexts
- **Batching**: For multiple requests, use Gemini's batch API

## Documentation Standards

When making changes that affect users:

1. Update `README.md` - Main overview
2. Update `SETUP.md` - If setup process changes
3. Update `STRUCTURE.md` - If architecture changes
4. Update `QUICKSTART.md` - If quick start steps change
5. Update this file (`GEMINI.md`) - If development patterns change

## Quick Reference: Where to Make Common Changes

| What to Change | Primary File | Secondary Files |
|----------------|-------------|-----------------|
| LLM Provider | `backend/app/agents/assistant0.py` | `backend/pyproject.toml`, config files |
| Agent Behavior | `backend/app/agents/assistant0.py` | Documentation |
| Agent Tools | `backend/app/agents/tools/` | `backend/app/agents/assistant0.py` |
| Chat UI | `frontend/src/pages/ChatPage.tsx` | `frontend/src/components/chat-window.tsx` |
| API Endpoints | `backend/app/api/routes/` | `backend/app/api/api_router.py` |
| Auth Flow | `backend/app/core/auth.py` | `frontend/src/main.tsx` |
| Token Vault (OAuth) | `frontend/src/components/auth0-ai/` | `backend/app/core/auth0_ai.py` |
| Environment Setup | `dev.nix` | `.env.example` files |
| Dependencies | `pyproject.toml` or `package.json` | `dev.nix` (if NIX packages) |
| Styling | Tailwind classes in React components | `tailwind.config.js`, shadcn/ui components |

## Firebase Studio Specific Tips

### Preview URLs
Firebase Studio generates dynamic URLs like:
- Backend: `https://8000-WORKSPACE_ID.idx.google.com`
- Frontend: `https://5173-WORKSPACE_ID.idx.google.com`

These are auto-configured in `dev.nix` using `$WEB_HOST` variable.

### Background vs Foreground Tasks
- Use `isBackground: true` for servers that run indefinitely
- Use `isBackground: false` for one-time setup tasks
- Current config runs servers as **foreground tasks** in `onStart`

### Debugging NIX Issues
- Check `.idx/` directory is not in `.gitignore`
- Verify NIX syntax with `nix-instantiate --parse`
- Look at Firebase Studio logs for initialization errors

## Advanced Topics

### Adding Database Support
1. Add PostgreSQL to NIX packages
2. Add SQLModel/SQLAlchemy to dependencies
3. Create database models in `backend/app/models/`
4. Add connection in `backend/app/core/db.py`
5. Update `onStart` to initialize database

### Implementing RAG (Retrieval Augmented Generation)
1. Add vector database (ChromaDB/Pinecone) to dependencies
2. Create embeddings in `backend/app/core/embeddings.py`
3. Add retrieval tools to agent
4. Create document upload UI in frontend

### Multi-Agent Systems
1. Create new agent files in `backend/app/agents/`
2. Add to `langgraph.json` configuration
3. Implement agent coordination logic
4. Update frontend to select agents

## Questions to Ask Before Making Changes

1. **Does this change affect authentication?** → Update Auth0 docs
2. **Does this add new dependencies?** → Update package files and NIX
3. **Does this change the setup process?** → Update SETUP.md
4. **Does this affect Firebase Studio behavior?** → Update dev.nix
5. **Does this impact security?** → Review carefully, document thoroughly
6. **Is this breaking change?** → Update version number, document migration

## Getting Help

- **Firebase Studio docs**: https://firebase.google.com/docs/studio
- **NIX reference**: https://nix.dev/
- **FastAPI docs**: https://fastapi.tiangolo.com/
- **LangChain docs**: https://python.langchain.com/
- **LangGraph docs**: https://langchain-ai.github.io/langgraph/
- **React docs**: https://react.dev/

## Final Notes

This template is designed to be:
- **Beginner-friendly**: Clear structure, good documentation
- **Production-ready**: Auth, security, best practices
- **Extensible**: Easy to add features
- **Firebase Studio native**: Leverages IDX capabilities

When making improvements, maintain these principles. Prioritize user experience and clear documentation over clever code.

---

**Last Updated**: December 4, 2025
**Template Version**: 0.1.0
**Target AI**: Google Gemini
