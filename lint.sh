#!/bin/bash

# This script runs linter for bash and YAML files in Fabrica root and for
# generated network configs in 'e2e/__tmp__' directory. It fails if generated
# network configs are missing.
#
# Required libs: shellcheck and yamllint

set -e

FABRICA_HOME="$(dirname "$0")"
shellcheck "$FABRICA_HOME"/*.sh
shellcheck "$FABRICA_HOME"/e2e-network/*.sh

EXPECTED_NETWORKS=(
  "$FABRICA_HOME/e2e/__tmp__/network-01-simple"
  "$FABRICA_HOME/e2e/__tmp__/network-02-simple-tls"
  "$FABRICA_HOME/e2e/__tmp__/network-03-simple-raft"
  "$FABRICA_HOME/e2e/__tmp__/network-04-simple-2chaincodes"
  "$FABRICA_HOME/e2e/__tmp__/network-05-2orgs"
  "$FABRICA_HOME/e2e/__tmp__/network-06-2orgs-tls"
  "$FABRICA_HOME/e2e/__tmp__/network-07-2orgs-raft"
)

for network in "${EXPECTED_NETWORKS[@]}"; do
  if [ -z "$(ls -A "$network")" ]; then
    echo "Missing network $network"
    exit 1
  fi

  echo "Linting network $network"

  # shellcheck disable=2044
  for file in $(find "$network" -name "*.sh"); do
    shellcheck "$file"
  done

  yamllint "$network"

done
