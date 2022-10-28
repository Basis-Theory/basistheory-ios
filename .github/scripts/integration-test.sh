#!/bin/bash

set -eo pipefail

xcodebuild clean test DEV_BT_API_KEY=${DEV_BT_API_KEY} \
    -workspace ./IntegrationTester/IntegrationTester.xcworkspace \
    -scheme IntegrationTester-CI \
    -destination platform="iOS Simulator,OS=15.2,name=iPhone 13 Pro" \
    | xcpretty
