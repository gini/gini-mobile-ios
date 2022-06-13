#!/bin/sh
set -eo pipefail

gpg --quiet --batch --yes --decrypt --passphrase="$IOS_CERTS_SECRET" --output ./.github/secrets/Bank_SDK_Example_Distribution.mobileprovision.mobileprovision ./.github/secrets/Bank_SDK_Example_Distribution.mobileprovision.gpg
gpg --quiet --batch --yes --decrypt --passphrase="$IOS_CERTS_SECRET" --output ./.github/secrets/ios_distribution_universal.p12 ./.github/secrets/ios_distribution_universal.p12.gpg

mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles

cp ./.github/secrets/Bank_SDK_Example_Distribution.mobileprovision.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/Bank_SDK_Example_Distribution.mobileprovision.mobileprovision


security create-keychain -p "" build.keychain
security import ./.github/secrets/Certificates.p12 -t agg -k ~/Library/Keychains/build.keychain -P "" -A

security list-keychains -s ~/Library/Keychains/build.keychain
security default-keychain -s ~/Library/Keychains/build.keychain
security unlock-keychain -p "" ~/Library/Keychains/build.keychain

security set-key-partition-list -S apple-tool:,apple: -s -k "" ~/Library/Keychains/build.keychain