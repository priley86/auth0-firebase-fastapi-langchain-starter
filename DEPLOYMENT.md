# Production Deployment Guide

This guide covers deploying your AI assistant to production using Google Cloud Run for backend services and Firebase Hosting for the frontend.

## Architecture Overview

This template uses Firebase's recommended architecture for dynamic applications (see [Firebase Hosting Documentation](https://firebase.google.com/docs/hosting)):
- **Frontend**: Static assets served via Firebase Hosting (CDN-optimized)
- **Backend Services**: Dynamic server-side logic on Google Cloud Run (auto-scaling containers)

### Deployment Components

1. **LangGraph Server** → Google Cloud Run (AI agent runtime)
2. **FastAPI Backend** → Google Cloud Run (API server with Auth0)
3. **React Frontend** → Firebase Hosting (Static site with CDN)

## Prerequisites

### Required Accounts
- [Google Cloud Platform](https://console.cloud.google.com/) account
- [Auth0](https://auth0.com/) account (already configured)
- [Firebase](https://console.firebase.google.com/) account (for frontend hosting)

### Required Tools
- [gcloud CLI](https://cloud.google.com/sdk/docs/install) installed and configured
- [Firebase CLI](https://firebase.google.com/docs/cli) installed

### Enable Google Cloud APIs

```bash
# Set your project ID
gcloud config set project your-project-id

# Enable required APIs
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
```

## Deployment Steps

### Step 1: Configure Production Environment

Create and configure your production environment file:

```bash
# Copy the example file
cd backend
cp .env.production.example .env.production
```

Edit `backend/.env.production` with your credentials:

```bash
# Google Cloud Platform
GCP_PROJECT_ID="your-project-id"
GCP_REGION="us-central1"

# Auth0 (from your Auth0 Dashboard)
AUTH0_DOMAIN="your-tenant.auth0.com"
AUTH0_CLIENT_ID="your-client-id"
AUTH0_CLIENT_SECRET="your-client-secret"
AUTH0_SECRET="generate-with-openssl-rand-hex-32"

# LLM Provider
OPENAI_API_KEY="your-openai-api-key"

# Optional: LangSmith tracing
LANGCHAIN_API_KEY="your-langsmith-api-key"
LANGCHAIN_TRACING_V2="true"
```

**Note:** The deployment scripts will automatically load variables from this file.

### Step 2: Deploy LangGraph Server

The LangGraph server hosts your AI agents and needs to be externally accessible.

```bash
# Make script executable (first time only)
chmod +x scripts/deploy-langgraph.sh

# Run deployment
./scripts/deploy-langgraph.sh
```

The script will:
1. Build a Docker image with your LangGraph server
2. Push it to Google Container Registry
3. Deploy it to Cloud Run
4. Output the service URL

#### Save the LangGraph URL

After deployment completes, you'll see:
```
LangGraph Server URL: https://langgraph-server-xxx-uc.a.run.app
```

**Add this URL to `backend/.env.production`:**
```bash
LANGGRAPH_EXTERNAL_URL="https://langgraph-server-xxx-uc.a.run.app"
```

### Step 3: Deploy FastAPI Backend

The backend API handles authentication and connects to your LangGraph server.

```bash
# Make script executable (first time only)
chmod +x scripts/deploy-backend.sh

# Run deployment (uses backend/.env.production)
./scripts/deploy-backend.sh
```

#### Save the Backend URL

After deployment completes, you'll see:
```
Backend API URL: https://backend-api-xxx-uc.a.run.app
```

**Copy this URL** - you'll need it for Auth0 configuration and frontend deployment.

#### Update Auth0 Application Settings

1. Go to your [Auth0 Dashboard](https://manage.auth0.com/)
2. Navigate to **Applications** > **Applications** > Your Application
3. Update the following settings:

**Allowed Callback URLs:**
```
https://backend-api-xxx-uc.a.run.app/api/callback
```

**Allowed Logout URLs:**
```
https://your-frontend-domain.web.app
```

**Allowed Web Origins:**
```
https://your-frontend-domain.web.app
```

### Step 4: Deploy Frontend to Firebase Hosting

#### Initialize Firebase

```bash
# Install Firebase CLI (if not already installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project (first time only)
firebase init hosting
```

When prompted:
- **Public directory:** Select `frontend/dist`
- **Configure as single-page app:** Yes
- **Set up automatic builds:** No (we'll do manual builds)

#### Configure Frontend Environment

Create `frontend/.env.production`:

```env
# Backend API URL (from Step 2)
VITE_API_URL=https://backend-api-xxx-uc.a.run.app
```

#### Build and Deploy

```bash
# Build the frontend
cd frontend
npm run build

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

#### Save the Frontend URL

After deployment, you'll see:
```
Hosting URL: https://your-project.web.app
```

#### Update Backend CORS

Now that you have your frontend URL, update `backend/.env.production`:

```bash
FRONTEND_HOST="https://your-project.web.app"
BACKEND_CORS_ORIGINS="https://your-project.web.app"
```

Redeploy backend with updated CORS:
```bash
./scripts/deploy-backend.sh
```

#### Update Auth0 (Again)

Go back to Auth0 and update with your actual frontend URL:

**Allowed Logout URLs:**
```
https://your-project.web.app
```

**Allowed Web Origins:**
```
https://your-project.web.app
```

### Alternative: Deploy from Firebase Studio UI

If you're using Firebase Studio, you can deploy using the **Deploy to Cloud Run** button:

**For LangGraph Server:**
- **Deploy Path**: `backend`
- **Dockerfile**: `Dockerfile.langgraph`
- **Port**: `54367`

**For FastAPI Backend:**
- **Deploy Path**: `backend`
- **Dockerfile**: `Dockerfile`
- **Port**: `8000`

Firebase Studio will automatically build, push, and deploy your containers to Cloud Run. Make sure to set the environment variables in the Cloud Run configuration.

## Verification

### Test Your Deployment

1. **Open your frontend:** `https://your-project.web.app`
2. **Login with Auth0**
3. **Send a message to the AI assistant**
4. **Verify the response**

### Check Service Health

```bash
# LangGraph health check
curl https://langgraph-server-xxx-uc.a.run.app/health

# Backend health check
curl https://backend-api-xxx-uc.a.run.app/health
```

## Monitoring and Logs

### View Logs

```bash
# LangGraph logs
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=langgraph-server" --limit 50

# Backend logs
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=backend-api" --limit 50

# Or use the scripts
gcloud run services logs langgraph-server --region $GCP_REGION
gcloud run services logs backend-api --region $GCP_REGION
```

### View Metrics

Visit Cloud Console:
- LangGraph: `https://console.cloud.google.com/run/detail/$GCP_REGION/langgraph-server/metrics`
- Backend: `https://console.cloud.google.com/run/detail/$GCP_REGION/backend-api/metrics`

## Cost Optimization

Cloud Run pricing is based on:
- **CPU:** Only charged when handling requests
- **Memory:** Only charged when handling requests
- **Requests:** $0.40 per million requests
- **Free tier:** 2 million requests/month, 360,000 GB-seconds/month

### Tips to Reduce Costs

1. **Set resource limits:**
   ```bash
   --memory 512Mi    # Reduce if possible
   --cpu 1           # Sufficient for most workloads
   ```

2. **Limit maximum instances:**
   ```bash
   --max-instances 10  # Prevent runaway scaling
   ```

3. **Set minimum instances to 0:**
   ```bash
   --min-instances 0  # Scale to zero when idle
   ```

4. **Use appropriate timeouts:**
   ```bash
   --timeout 60  # Backend doesn't need long timeouts
   --timeout 300 # LangGraph may need more time for complex queries
   ```

## Troubleshooting

### Container Fails to Start

**Check logs:**
```bash
gcloud run services logs langgraph-server --limit 50
```

**Common issues:**
- Missing environment variables
- Port mismatch (make sure Dockerfile EXPOSE matches --port)
- Insufficient memory/CPU

**Solution:**
```bash
# Increase resources
gcloud run services update langgraph-server \
  --memory 2Gi \
  --cpu 2
```

### High Latency

**Check cold start times:**
- Cloud Run instances may take 1-2 seconds to start
- Consider using `--min-instances 1` to keep one warm

**Optimize:**
```bash
# Keep at least one instance running
gcloud run services update langgraph-server --min-instances 1
```

### Authentication Errors

**Verify Auth0 configuration:**
- Callback URLs match exactly (including https://)
- CORS origins include your frontend domain
- Client Secret is correct

**Check backend logs:**
```bash
gcloud run services logs backend-api --limit 50
```

### LangGraph Connection Issues

**Verify URL is correct:**
```bash
# Test from local machine
curl https://langgraph-server-xxx-uc.a.run.app/health
```

**Check backend environment:**
```bash
gcloud run services describe backend-api \
  --format="value(spec.template.spec.containers[0].env)"
```

## Updating Deployments

### Update Code

After making code changes, simply redeploy:

```bash
# Redeploy LangGraph
./scripts/deploy-langgraph.sh

# Redeploy Backend
./scripts/deploy-backend.sh

# Rebuild and redeploy Frontend
cd frontend
npm run build
firebase deploy --only hosting
```

### Update Environment Variables

```bash
# Update single variable
gcloud run services update backend-api \
  --update-env-vars NEW_VAR=value

# Update multiple variables
gcloud run services update backend-api \
  --update-env-vars VAR1=value1,VAR2=value2
```

### Rollback to Previous Version

```bash
# List revisions
gcloud run revisions list --service backend-api

# Rollback to specific revision
gcloud run services update-traffic backend-api \
  --to-revisions=backend-api-00001-abc=100
```

## CI/CD Setup (Optional)

### GitHub Actions

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Cloud Run

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - id: auth
        uses: google-github-actions/auth@v1
        with:
          credentials_json: ${{ secrets.GCP_CREDENTIALS }}
      
      - name: Deploy LangGraph
        run: |
          export GCP_PROJECT_ID=${{ secrets.GCP_PROJECT_ID }}
          export OPENAI_API_KEY=${{ secrets.OPENAI_API_KEY }}
          ./scripts/deploy-langgraph.sh
      
      - name: Deploy Backend
        run: |
          export GCP_PROJECT_ID=${{ secrets.GCP_PROJECT_ID }}
          export AUTH0_DOMAIN=${{ secrets.AUTH0_DOMAIN }}
          # ... other secrets
          ./scripts/deploy-backend.sh
```

## Getting Help

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Firebase Hosting Documentation](https://firebase.google.com/docs/hosting)
- [GitHub Issues](https://github.com/priley86/auth0-firebase-fastapi-langchain-starter/issues)
