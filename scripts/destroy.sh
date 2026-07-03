#!/usr/bin/env bash
# Full teardown. On a personal sub, an idle Foundry+Search install still bills; destroy when done.
set -euo pipefail
BASE_NAME="${1:?base name}"
az group delete -n "rg-formwork-${BASE_NAME}" --yes --no-wait
echo "Deletion started for rg-formwork-${BASE_NAME}."
