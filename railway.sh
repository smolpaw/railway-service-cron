#!/bin/bash

# Validate SERVICES_ID is provided
if [ -z "$SERVICES_ID" ]; then
  echo "Error: SERVICES_ID environment variable is required"
  exit 1
fi

# Make Railway GraphQL API request
railway_api_request() {
  local query="$1"
  
  curl --silent --request POST --max-time 60 \
    --url https://backboard.railway.com/graphql/v2 \
    --header "Authorization: Bearer $RAILWAY_ACCOUNT_TOKEN" \
    --header 'Content-Type: application/json' \
    --data "$query"
}

# Get latest deployment info of a service
get_latest_deployment_info() {
  local service_id="$1"
  
  railway_api_request "{\"query\":\"query { deployments(first: 1, input: { projectId: \\\"$RAILWAY_PROJECT_ID\\\", environmentId: \\\"$RAILWAY_ENVIRONMENT_ID\\\", serviceId: \\\"$service_id\\\" }) { edges { node { id status service { name } } } } }\"}" | \
    jq -r '.data.deployments.edges[0].node // empty'
}

# Shutdown a service
shutdown_service() {
  local service_id="$1"
  
  echo "Checking deployment status..."
  local deployment_info=$(get_latest_deployment_info "$service_id")
  
  if [ -z "$deployment_info" ] || [ "$deployment_info" = "null" ] || [ "$deployment_info" = "empty" ]; then
    echo "No deployment found for service ($service_id)"
    return 1
  fi
  
  local service_name=$(echo "$deployment_info" | jq -r '.service.name // "Unknown"')
  local deployment_id=$(echo "$deployment_info" | jq -r '.id // empty')
  local deployment_status=$(echo "$deployment_info" | jq -r '.status // empty')
  
  echo "Shutting Down Service: $service_name ($service_id)"
  echo "Latest deployment status: $deployment_status"
  
  if [ "$deployment_status" = "REMOVED" ]; then
    echo "⏭️  Service already stopped. Skipping..."
    echo ""
    return 0
  fi
  
  if [ -z "$deployment_id" ] || [ "$deployment_id" = "null" ]; then
    echo "No deployment ID found"
    return 1
  fi
  
  echo "Stopping deployment: $deployment_id"
  railway_api_request "{\"query\":\"mutation { deploymentRemove(id: \\\"$deployment_id\\\") }\"}" | \
    jq '.data.deploymentRemove // .errors'
  echo ""
}

# Deploy a service
deploy_service() {
  local service_id="$1"
  
  echo "Checking deployment status..."
  local deployment_info=$(get_latest_deployment_info "$service_id")
  
  if [ -z "$deployment_info" ] || [ "$deployment_info" = "null" ] || [ "$deployment_info" = "empty" ]; then
    echo "No deployment found for service ($service_id)"
    return 1
  fi
  
  local service_name=$(echo "$deployment_info" | jq -r '.service.name // "Unknown"')
  local deployment_id=$(echo "$deployment_info" | jq -r '.id // empty')
  local deployment_status=$(echo "$deployment_info" | jq -r '.status // empty')
  
  echo "Deploying Service: $service_name ($service_id)"
  echo "Latest deployment status: $deployment_status"
  
  if [ "$deployment_status" != "SUCCESS" ] && [ "$deployment_status" != "REMOVED" ]; then
    echo "⏭️  Service not ready for deployment. Skipping deployment..."
    echo ""
    return 0
  fi
  
  if [ "$deployment_status" = "SUCCESS" ]; then
    echo "✅ Service already running. Skipping deployment..."
    echo ""
    return 0
  fi
  
  if [ -z "$deployment_id" ] || [ "$deployment_id" = "null" ]; then
    echo "No deployment ID found for redeployment"
    return 1
  fi
  
  echo "Triggering deployment redeploy: $deployment_id"
  railway_api_request "{\"query\":\"mutation { deploymentRedeploy(id: \\\"$deployment_id\\\", usePreviousImageTag: true) { id } }\"}" | \
    jq '.data.deploymentRedeploy // .errors'
  echo ""
}

# Validate account token by testing a simple query
echo "Validating account token..."
response=$(railway_api_request "{\"query\":\"query { project(id: \\\"$RAILWAY_PROJECT_ID\\\") { name } }\"}")

errors=$(echo "$response" | jq -r '.errors // empty')
project_name=$(echo "$response" | jq -r '.data.project.name // empty')

if [ -n "$errors" ]; then
  echo "❌ Invalid or expired account token"
  echo "Error: $errors"
  exit 1
fi

if [ -z "$project_name" ] || [ "$project_name" = "null" ]; then
  echo "❌ Invalid account token - unable to access project"
  exit 1
fi

echo "✅ Token valid - connected to project: $project_name"
echo ""

# Execute intent
case "$1" in
    "up")
        echo "=== Bringing Services UP ==="
        IFS=',' read -ra SERVICE_ARRAY <<< "$SERVICES_ID"
        for service in "${SERVICE_ARRAY[@]}"; do
            service=$(echo "$service" | xargs)
            deploy_service "$service"
        done
        ;;
    "down")
        echo "=== Bringing Services DOWN ==="
        IFS=',' read -ra SERVICE_ARRAY <<< "$SERVICES_ID"
        for service in "${SERVICE_ARRAY[@]}"; do
            service=$(echo "$service" | xargs)
            shutdown_service "$service"
        done
        ;;
    *)
        echo "Error: Invalid argument '$1'"
        echo "Usage: $0 [up|down]"
        exit 1
        ;;
esac