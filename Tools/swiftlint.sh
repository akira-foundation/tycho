#!/bin/zsh
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v swiftlint >/dev/null 2>&1; then
  echo "SwiftLint is not on the PATH. Install it with: brew install swiftlint"
  echo "CI pins 0.65.1 in .github/workflows/test.yml."
  exit 1
fi

echo "==> swiftlint $(swiftlint version)"

if [ "${1:-}" = "--fix" ]; then
  shift
  swiftlint lint --fix --progress "$@"
  echo "Files were rewritten. Read the diff before committing."
  exit 0
fi

swiftlint lint --strict --quiet "$@"
echo "SwiftLint passes."
