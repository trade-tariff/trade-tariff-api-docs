#!/usr/bin/env bash

set -euo pipefail

if rg -n 'source/v2/openapi\.yaml|generate\.js' README.md; then
  echo
  echo 'README.md still references the retired source/v2 OpenAPI workflow.'
  echo 'Update the docs to describe the current canonical reference source instead.'
  exit 1
fi

echo 'Reference workflow docs check passed.'
