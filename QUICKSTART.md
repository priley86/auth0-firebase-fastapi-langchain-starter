# Quick Start Reference

## 🚀 One-Click Setup (Recommended)

[![Open in IDX](https://cdn.idx.dev/btn/open_dark_32@2x.png)](https://idx.google.com/new?template=https://github.com/priley86/auth0-firebase-fastapi-langchain-starter)

1. Click the button above
2. Wait for initialization
3. Configure `.env` files (see below)
4. Start chatting!

## ⚡ Local Development

### Prerequisites
- Python 3.13+
- Node.js 20+
- uv (Python package manager)
- Auth0 account
- LLM API key (OpenAI or Google Gemini)

### Quick Commands

```bash
# Backend
cd backend
uv sync
cp .env.example .env  # Edit with your credentials
source .venv/bin/activate
fastapi dev app/main.py  # Terminal 1

# LangGraph
cd backend
source .venv/bin/activate
langgraph dev --port 54367  # Terminal 2

# Frontend
cd frontend
npm install
cp .env.example .env  # Edit with your credentials
npm run dev  # Terminal 3
```

## 🔑 Required Environment Variables

### Backend `.env`
```env
AUTH0_DOMAIN=your-tenant.auth0.com
AUTH0_CLIENT_ID=your-client-id
AUTH0_CLIENT_SECRET=your-client-secret
AUTH0_SECRET=generate-with-openssl-rand-hex-32
OPENAI_API_KEY=your-google-ai-key  # Get at: https://aistudio.google.com/app/apikey
```

### Frontend `.env`
```env
VITE_API_URL=http://localhost:8000
```

## 🔧 Auth0 Configuration

**Application Type**: Regular Web Application

**Required URLs**:
- Callback: `http://localhost:5173/callback`
- Logout: `http://localhost:5173`
- Web Origins: `http://localhost:5173`

For Firebase Studio, also add:
- `https://5173-YOUR-WORKSPACE.idx.google.com/callback`
- `https://5173-YOUR-WORKSPACE.idx.google.com`

## 📦 Tech Stack

| Component | Technology |
|-----------|-----------|
| Backend | FastAPI + Python 3.13 |
| AI Agent | LangGraph (OpenAI/Gemini) |
| Frontend | React 19 + Vite + TypeScript |
| Styling | Tailwind CSS |
| Auth | Auth0 |
| Dev Env | Firebase Studio (Project IDX) + NIX |

## 📂 Key Files to Edit

| Purpose | File |
|---------|------|
| Agent logic | `backend/app/agents/assistant0.py` |
| Agent tools | `backend/app/agents/tools/google_calendar.py` |
| API routes | `backend/app/api/routes/chat.py` |
| User profile | `backend/app/api/routes/profile.py` |
| Frontend UI | `frontend/src/pages/ChatPage.tsx` |
| Layout | `frontend/src/components/layout.tsx` |
| Auth UI | `frontend/src/components/auth0/user-button.tsx` |
| Config | `.idx/dev.nix` |

## 🐛 Common Issues

### "Callback URL mismatch"
→ Check Auth0 application settings match your URLs

### "Module not found" (Python)
→ Run `cd backend && uv sync`

### "Module not found" (Node)
→ Run `cd frontend && npm install`

### "Cannot connect to backend"
→ Ensure FastAPI server is running on port 8000

### "Agent not responding"
→ Check LangGraph server is running on port 54367

## 📚 Documentation

- [Full README](README.md) - Complete overview
- [Setup Guide](SETUP.md) - Detailed setup instructions
- [Project Structure](STRUCTURE.md) - Architecture and file organization
- [Contributing](CONTRIBUTING.md) - Contribution guidelines

## 🔗 Useful Links

- [Auth0 Docs](https://auth0.com/docs)
- [FastAPI Docs](https://fastapi.tiangolo.com/)
- [LangGraph Docs](https://langchain-ai.github.io/langgraph/)
- [React Docs](https://react.dev/)
- [Firebase Studio Docs](https://firebase.google.com/docs/studio)

## 💡 Next Steps

1. ✅ Get it running locally
2. 🎨 Customize the UI
3. 🤖 Enhance the AI agent
4. 🛠️ Add new tools/capabilities
5. 🚀 Deploy to production

## 📞 Support

- [GitHub Issues](https://github.com/priley86/auth0-firebase-fastapi-langchain-starter/issues)
- [Auth0 Community](https://community.auth0.com/)
- [LangChain Discord](https://discord.gg/langchain)
