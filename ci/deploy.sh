#!/usr/bin/env bash

source "./ci/lib/travis_helpers.sh"

set -euo pipefail

travis_fold_open "Install dependencies" "Installing deployment dependencies…"
brew update
brew install carthage
travis_fold_close "Install dependencies"

travis_fold_open "Archive" "Creating release archive…"
carthage build --no-skip-current && carthage archive "$PROJECT_NAME"
travis_fold_close "Archive"
