#!/usr/bin/env bash
# Deploy a scenario to your personal sub. Usage: ./scripts/deploy.sh rag mydemo eastus2
set -euo pipefail
SCENARIO="${1:?scenario (rag|agentic|batch-eval|ingest)}"
BASE_NAME="${2:?base name, 3-20 chars}"
LOCATION="${3:-eastus2}"
RG="rg-formwork-${BASE_NAME}"

az group create -n "$RG" -l "$LOCATION" --tags managedBy=formwork autoTeardown=true
az deployment group create -g "$RG" \
  -f "scenarios/${SCENARIO}/${SCENARIO}.bicep" \
  -p baseName="$BASE_NAME"
echo
echo "Deployed. Tear down with: ./scripts/destroy.sh ${BASE_NAME}"
