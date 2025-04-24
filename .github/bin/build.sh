#!/bin/bash

# update fastlane
bundle update fastlane

# run fastlane
bundle exec fastlane "build_health_example_app" rollout:"$ROLLOUT" || exit 1
