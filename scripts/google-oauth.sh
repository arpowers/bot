#!/bin/bash
# Google OAuth Flow - Run locally to get tokens

# Load credentials from .env
source .env

CLIENT_ID="${GOOGLE_OAUTH_CLIENT_ID}"
CLIENT_SECRET="${GOOGLE_OAUTH_CLIENT_SECRET}"
REDIRECT_URI="http://localhost:8080"
SCOPES="https://www.googleapis.com/auth/gmail.modify https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive.readonly"

# URL encode scopes
ENCODED_SCOPES=$(echo "$SCOPES" | sed 's/ /%20/g')

echo "=== Google OAuth Setup ==="
echo ""
echo "1. Open this URL in your browser:"
echo ""
echo "https://accounts.google.com/o/oauth2/v2/auth?client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}&response_type=code&scope=${ENCODED_SCOPES}&access_type=offline&prompt=consent"
echo ""
echo "2. Sign in with andrew@fiction.com"
echo "3. After approving, you'll be redirected to localhost (it will fail to load)"
echo "4. Copy the 'code' parameter from the URL"
echo ""
read -p "Paste the code here: " AUTH_CODE

echo ""
echo "Exchanging code for tokens..."

# Exchange code for tokens
RESPONSE=$(curl -s -X POST "https://oauth2.googleapis.com/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=${CLIENT_ID}" \
  -d "client_secret=${CLIENT_SECRET}" \
  -d "code=${AUTH_CODE}" \
  -d "grant_type=authorization_code" \
  -d "redirect_uri=${REDIRECT_URI}")

# Extract tokens
ACCESS_TOKEN=$(echo "$RESPONSE" | jq -r '.access_token')
REFRESH_TOKEN=$(echo "$RESPONSE" | jq -r '.refresh_token')

if [ "$ACCESS_TOKEN" == "null" ] || [ -z "$ACCESS_TOKEN" ]; then
  echo "Error getting tokens:"
  echo "$RESPONSE" | jq .
  exit 1
fi

echo ""
echo "=== SUCCESS ==="
echo ""
echo "Add these to your .env and Fly secrets:"
echo ""
echo "GOOGLE_ACCESS_TOKEN=\"${ACCESS_TOKEN}\""
echo "GOOGLE_REFRESH_TOKEN=\"${REFRESH_TOKEN}\""
echo ""
echo "Access token expires in 1 hour. Refresh token is long-lived."
echo ""
echo "To add to Fly:"
echo "flyctl secrets set GOOGLE_ACCESS_TOKEN=\"${ACCESS_TOKEN}\" GOOGLE_REFRESH_TOKEN=\"${REFRESH_TOKEN}\""
