#!/bin/bash
# Railway Deployment Script for OpusSensus Plus
# This script provides guidance and commands to deploy the application on Railway.
# Note: Some steps may need to be performed manually via the Railway dashboard or CLI.

echo "Starting Railway deployment setup for OpusSensus Plus..."

# Step 1: Ensure Railway CLI is installed
echo "Checking for Railway CLI..."
if ! command -v railway &> /dev/null; then
    echo "Railway CLI not found. Installing Railway CLI..."
    # Installation command for macOS (adjust if on a different OS)
    brew install railway
    if [ $? -ne 0 ]; then
        echo "Error installing Railway CLI. Please install it manually from https://railway.app/cli"
        exit 1
    fi
else
    echo "Railway CLI is already installed."
fi

# Step 2: Login to Railway
echo "Please ensure you are logged into Railway. Run 'railway login' if needed."
read -p "Are you logged in? (y/n): " logged_in
if [ "$logged_in" != "y" ] && [ "$logged_in" != "Y" ]; then
    railway login
    if [ $? -ne 0 ]; then
        echo "Login failed. Please login manually using 'railway login'."
        exit 1
    fi
fi

# Step 3: Initialize Railway project if not already done
echo "Initializing or linking to a Railway project..."
if [ ! -f "railway.json" ]; then
    railway init
    if [ $? -ne 0 ]; then
        echo "Failed to initialize Railway project. Please create a project manually on Railway dashboard."
        exit 1
    fi
else
    echo "Railway project configuration found. Linking to existing project..."
    railway link
fi

# Step 4: Deploy main application services
echo "Deploying application services to Railway..."
# Deploy web and server components as separate services if not using a single Dockerfile
# This assumes the Dockerfile in admin/deploy/docker is for a combined setup
railway up
if [ $? -ne 0 ]; then
    echo "Deployment failed. Check Railway dashboard or CLI output for errors."
    exit 1
fi

# Step 5: Setup additional services (Database and Redis)
echo "Setting up additional services on Railway..."
echo "Railway manages databases as separate services. You need to create them via the dashboard or CLI."
read -p "Do you want to create database and Redis services now? (y/n): " create_services
if [ "$create_services" = "y" ] || [ "$create_services" = "Y" ]; then
    echo "Choose database type:"
    echo "1. MySQL"
    echo "2. PostgreSQL (recommended for advanced features and JSON support)"
    read -p "Enter choice (1 or 2): " db_choice
    if [ "$db_choice" = "1" ]; then
        echo "Creating MySQL service..."
        railway service add mysql
        if [ $? -ne 0 ]; then
            echo "Failed to create MySQL service. Please create it manually on Railway dashboard."
        fi
    elif [ "$db_choice" = "2" ]; then
        echo "Creating PostgreSQL service..."
        railway service add postgresql
        if [ $? -ne 0 ]; then
            echo "Failed to create PostgreSQL service. Please create it manually on Railway dashboard."
        fi
    else
        echo "Invalid choice. Skipping database creation. Please create it manually on Railway dashboard."
    fi
    
    echo "Creating Redis service..."
    railway service add redis
    if [ $? -ne 0 ]; then
        echo "Failed to create Redis service. Please create it manually on Railway dashboard."
    fi
    
    echo "Services created. Ensure they are configured with the correct environment variables."
    echo "Check Railway dashboard to get connection strings and update your application configuration."
else
    echo "Skipping service creation. Ensure database and Redis are set up on Railway dashboard."
fi

# Step 6: Environment variables setup
echo "Ensure environment variables are set for your services on Railway."
echo "You can set them via the Railway dashboard or using 'railway variables set' command."
echo "Variables needed based on docker-compose.yaml for MySQL:"
echo " - MYSQL_DATABASE=qmPlus"
echo " - MYSQL_USER=gva"
echo " - MYSQL_PASSWORD=Aa@6447985"
echo "For PostgreSQL, ensure the correct connection string and credentials are set."
echo "Also, set the database type in your application configuration:"
echo " - DB_TYPE=pgsql (for PostgreSQL) or mysql (for MySQL)"
echo "Refer to your configuration files for other necessary variables."

# Step 7: Finalize deployment
echo "Deployment to Railway is in progress or completed."
echo "Check the Railway dashboard for deployment status and logs."
echo "If using separate services for web and server, ensure they are linked correctly."
echo "Run 'railway open' to open the dashboard in your browser."

echo "Railway deployment setup complete!"