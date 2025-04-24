#!/bin/bash

set -o pipefail

# update fastlane
bundle update fastlane

# Required since https://github.blog/2022-04-12-git-security-vulnerability-announced
git config --global --add safe.directory $GITHUB_WORKSPACE

RELEASE_NOTES=""
RELEASE_NOTES_FILE=""

TOKEN_DEPRECATED_WARNING_MESSAGE="⚠ This action will stop working with the next future major version of firebase-tools! Migrate to Service Account. See more: https://github.com/wzieba/Firebase-Distribution-Github-Action/wiki/FIREBASE_TOKEN-migration"

if [[ -z ${INPUT_RELEASENOTES} ]]; then
        RELEASE_NOTES="$(git log -1 --pretty=short)"
else
        RELEASE_NOTES=${INPUT_RELEASENOTES}
fi

if [[ ${INPUT_RELEASENOTESFILE} ]]; then
        RELEASE_NOTES=""
        RELEASE_NOTES_FILE=${INPUT_RELEASENOTESFILE}
fi

if [ -n "${INPUT_SERVICECREDENTIALSFILE}" ] ; then
    export GOOGLE_APPLICATION_CREDENTIALS="${INPUT_SERVICECREDENTIALSFILE}"
fi

if [ -n "${INPUT_SERVICECREDENTIALSFILECONTENT}" ] ; then
    cat <<< "${INPUT_SERVICECREDENTIALSFILECONTENT}" > service_credentials_content.json
    export GOOGLE_APPLICATION_CREDENTIALS="service_credentials_content.json"
fi

if [ -n "${INPUT_TOKEN}" ] ; then
    echo ${TOKEN_DEPRECATED_WARNING_MESSAGE}
    export FIREBASE_TOKEN="${INPUT_TOKEN}"
fi

# run fastlane
bundle exec fastlane "distribute_to_firebase" TOKEN:"${FIREBASE_TOKEN}" || exit 1
