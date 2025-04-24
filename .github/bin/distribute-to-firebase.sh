#!/bin/bash

# update fastlane
bundle update fastlane

# run fastlane
bundle exec fastlane "distribute_to_firebase" || exit 1
