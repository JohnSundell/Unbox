#!/usr/bin/env bash

source "./ci/lib/travis_helpers.sh"

set -euo pipefail

# Executing build actions
echo "Executing build actions: $BUILD_ACTIONS"
retry_attempts=0
until [ $retry_attempts -ge 2 ]
do
    xcrun xcodebuild $BUILD_ACTIONS \
        NSUnbufferedIO=YES \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -sdk "$TEST_SDK" \
        -destination "$TEST_DEST" \
        $EXTRA_ARGUMENTS \
            | xcpretty -c -f `xcpretty-travis-formatter` && break
    retry_attempts=$[$retry_attempts+1]
    sleep $retry_attempts
done

# Linting
travis_fold_open "Linting" "Linting CocoaPods specification…"
pod spec lint "${PODSPEC}.podspec" --quick
travis_fold_close "Linting"
