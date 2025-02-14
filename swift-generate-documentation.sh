#!/bin/sh

swift build

swift package \
     --allow-writing-to-directory ./docs \
     generate-documentation \
     --target NTP \
     --transform-for-static-hosting \
     --hosting-base-path NTP \
     --output-path ./docs
