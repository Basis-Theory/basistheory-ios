#!/bin/bash

set -eo pipefail

# hack to stop Xcode from complaining about missing plist file
cat <<EOT > ./IntegrationTester/Env.Local.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
</plist>
EOT

xcodebuild clean test DEV_BT_API_KEY=${DEV_BT_API_KEY} \
    -workspace ./IntegrationTester/IntegrationTester.xcworkspace \
    -scheme IntegrationTester-CI \
    -configuration Debug \
    -destination platform="iOS Simulator,OS=16.1,name=iPhone 14 Pro" \
    | xcpretty
