#!/bin/bash
set -e

# Deployment script for LangGraph Server to Google Cloud Run
# This makes your LangGraph server externally accessible

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  LangGraph Cloud Run Deployment${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Load production environment variables
ENV_FILE="$PROJECT_ROOT/backend/.env.production"
if [ -f "$ENV_FILE" ]; then
    echo -e "${BLUE}Loading environment variables from $ENV_FILE${NC}"
    source "$ENV_FILE"
else
    echo -e "${YELLOW}Warning: $ENV_FILE not found${NC}"
    echo "Create it from backend/.env.production.example or set environment variables manually"
    echo ""
fi

# Configuration
PROJECT_ID="${GCP_PROJECT_ID}"
REGION="${GCP_REGION:-us-central1}"
SERVICE_NAME="langgraph-server"
IMAGE_NAME="gcr.io/${PROJECT_ID}/${SERVICE_NAME}"

# Check required environment variables
if [ -z "$PROJECT_ID" ]; then
    echo -e "${RED}Error: GCP_PROJECT_ID is not set${NC}"
    echo "Set it in backend/.env.production or export GCP_PROJECT_ID='your-project-id'"
    exit 1
fi

if [ -z "$OPENAI_API_KEY" ]; then
    echo -e "${YELLOW}Warning: OPENAI_API_KEY is not set${NC}"
    echo "The deployment will continue, but you'll need to set it later"
fi

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}Error: gcloud CLI is not installed${NC}"
    echo "Install it from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Set the project
echo -e "${BLUE}Setting GCP project to ${PROJECT_ID}...${NC}"
gcloud config set project ${PROJECT_ID}

# Enable required APIs
echo -e "${BLUE}Enabling required Google Cloud APIs...${NC}"
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com

# Build the container image
echo -e "${BLUE}Building container image...${NC}"
echo "This may take a few minutes..."
cd backend
gcloud builds submit --tag ${IMAGE_NAME} -f Dockerfile.langgraph .

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to build container image${NC}"
    exit 1
fi

# Prepare environment variables for deployment
ENV_VARS="OPENAI_API_KEY=${OPENAI_API_KEY}"

# Add optional environment variables if set
if [ ! -z "$LANGCHAIN_API_KEY" ]; then
    ENV_VARS="${ENV_VARS},LANGCHAIN_API_KEY=${LANGCHAIN_API_KEY}"
fi

if [ ! -z "$LANGCHAIN_TRACING_V2" ]; then
    ENV_VARS="${ENV_VARS},LANGCHAIN_TRACING_V2=${LANGCHAIN_TRACING_V2}"
fi

# Deploy to Cloud Run
echo -e "${BLUE}Deploying to Cloud Run...${NC}"
gcloud run deploy ${SERVICE_NAME} \
  --image ${IMAGE_NAME} \
  --platform managed \
  --region ${REGION} \
  --allow-unauthenticated \
  --port 54367 \
  --memory 1Gi \
  --cpu 1 \
  --timeout 300 \
  --max-instances 10 \
  --set-env-vars "${ENV_VARS}"

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to deploy to Cloud Run${NC}"
    exit 1
fi

# Get the service URL
SERVICE_URL=$(gcloud run services describe ${SERVICE_NAME} --region ${REGION} --format 'value(status.url)')

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  ✓ Deployment Successful!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${GREEN}LangGraph Server URL:${NC}"
echo -e "${YELLOW}${SERVICE_URL}${NC}"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo ""
echo "1. Update your backend/.env file with:"
echo -e "   ${YELLOW}LANGGRAPH_EXTERNAL_URL=${SERVICE_URL}${NC}"
echo ""
echo "2. Test your deployment:"
echo -e "   ${YELLOW}curl ${SERVICE_URL}/health${NC}"
echo ""
echo "3. View logs:"
echo -e "   ${YELLOW}gcloud run services logs ${SERVICE_NAME} --region ${REGION}${NC}"
echo ""
echo "4. Monitor in Cloud Console:"
echo -e "   ${YELLOW}https://console.cloud.google.com/run/detail/${REGION}/${SERVICE_NAME}/metrics${NC}"
echo ""
