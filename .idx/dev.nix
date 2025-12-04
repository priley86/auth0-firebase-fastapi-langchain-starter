# To learn more about how to use Nix to configure your environment
# see: https://developers.google.com/idx/guides/customize-idx-env
{ pkgs, ... }: {
  # Which nixpkgs channel to use.
  channel = "stable-24.05"; # or "unstable"
  
  # Use https://search.nixos.org/packages to find packages
  packages = [
    pkgs.python3
    pkgs.uv
    pkgs.pipx
    pkgs.nodejs_22
  ];
  
  # Sets environment variables in the workspace
  env = {
    # LangGraph server URL
    LANGGRAPH_API_URL = "http://localhost:54367";
    
    # Backend API URL for frontend
    VITE_API_URL = "https://8000-$WEB_HOST";
    
    # Frontend URL for CORS
    FRONTEND_HOST = "https://5173-$WEB_HOST";
    
    # Backend CORS origins
    BACKEND_CORS_ORIGINS = "https://8000-$WEB_HOST,https://5173-$WEB_HOST";
  };
  
  idx = {
    # Search for the extensions you want on https://open-vsx.org/ and use "publisher.id"
    extensions = [
      "ms-python.python"
      "ms-python.vscode-pylance"
      "dbaeumer.vscode-eslint"
      "esbenp.prettier-vscode"
    ];
    
    # Enable previews
    previews = {
      enable = true;
      previews = {
        # Frontend preview on port 5173
        web = {
          command = ["npm" "run" "dev" "--" "--port" "$PORT" "--host" "0.0.0.0"];
          manager = "web";
          cwd = "frontend";
          env = {
            PORT = "$PORT";
          };
        };
      };
    };
    
    # Workspace lifecycle hooks
    workspace = {
      # Runs when a workspace is first created
      onCreate = {
        # Copy environment files
        copy-backend-env = "cp backend/.env.example backend/.env";
        copy-frontend-env = "cp frontend/.env.example frontend/.env";
        
        # Install frontend dependencies
        npm-install = "cd frontend && npm install";
        
        # Install backend dependencies
        backend-setup = "cd backend && uv sync --prerelease=allow";
        
        # Open editors for the following files by default, if they exist:
        default.openFiles = [ 
          ".idx/dev.nix" 
          "README.md" 
          "backend/app/main.py"
          "frontend/src/main.tsx"
        ];
      };
      
      # Runs when the workspace is (re)started
      onStart = {
        # Start the backend FastAPI server
        start-backend = "cd backend && uv run fastapi dev app/main.py --host 0.0.0.0 --port 8000";
        
        # Start the LangGraph server
        start-langgraph = "cd backend && uv run langgraph dev --port 54367 --host 0.0.0.0 --no-browser";
      };
    };
  };
}
