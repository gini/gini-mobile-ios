#!/bin/bash

# run fastlane
bundle exec fastlane "distribute_to_firebase" || exit 1
