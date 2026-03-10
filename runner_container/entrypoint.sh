#!/bin/bash
set -e

# These come from the ENV in Dockerfile or ACI Runtime
GH_PAT="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"
RESPONSE=$(curl -L \
            -X POST \
            -H "Accept: application/vnd.github+json" \
            -H "Authorization: Bearer " \
            -H "X-GitHub-Api-Version: 2022-11-28" \
            https://api.github.com/repos/https://github.com/DataAIShift/gh-pocs/actions/runners/registration-token)

          TOKEN=$(echo $RESPONSE | jq -r '.token')
          echo "RUNNER_TOKEN=$TOKEN" >> $GITHUB_OUTPUT

          if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
            echo "Error: Failed to generate runner token"
            echo "Response: $RESPONSE"
            exit 1
          fi



# 1. Configure the runner
# We use --unattended to avoid prompts and --replace to cleanup old sessions
./config.sh --url "https://github.com/DataAIShift/gh-pocs" \
            --token "$RUNNER_TOKEN" \
            --name "aci-runner-pratik" \
            --work "_work" \
            --unattended \
            --replace

# 2. Start the runner
# Use 'exec' so that the runner process becomes PID 1 
# This ensures the container stays running and handles signals correctly
exec ./run.sh