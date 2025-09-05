#!/bin/bash
set -e

# # Setup certificate and provisioning profile
# CERTIFICATE_PATH=$RUNNER_TEMP/build_certificate.p12
# PP_PATH=$RUNNER_TEMP/build_pp.mobileprovision
# KEYCHAIN_PATH=$RUNNER_TEMP/app-signing.keychain-db

# # Import certificate and provisioning profile from secrets
# echo -n "$BUILD_CERTIFICATE_BASE64" | base64 --decode --output $CERTIFICATE_PATH
# echo -n "$BUILD_PROVISION_PROFILE_BASE64" | base64 --decode --output $PP_PATH

# # Create temporary keychain
# security create-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH
# security set-keychain-settings -lut 21600 $KEYCHAIN_PATH
# security unlock-keychain -p "$KEYCHAIN_PASSWORD" $KEYCHAIN_PATH

# # Import certificate to keychain
# security import $CERTIFICATE_PATH -P "$P12_PASSWORD" -A -t cert -f pkcs12 -k $KEYCHAIN_PATH
# security list-keychain -d user -s $KEYCHAIN_PATH

# # Apply provisioning profile
# mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
# cp $PP_PATH ~/Library/MobileDevice/Provisioning\ Profiles

# # Setup manual signing using fastlane
# bundle exec fastlane "setup_manual_signing" project_path:"HealthSDK/GiniHealthSDKExample/GiniHealthSDKExample.xcodeproj" \
#   team_id:"$TEAM_ID" \
#   target:"GiniHealthSDKExample" \
#   bundle_identifier:"$APP_IDENTIFIER" \
#   profile_name:"$PROFILE_NAME" \
#   entitlements_file_path:"GiniHealthSDKExample/GiniHealthSDKExample.entitlements" \
#   ci:"true"

# Update credentials in the source code
sed -i '' \
  -e 's/clientID = "client_id"/clientID = "gini-mobile-test"/' \
  -e "s/clientPassword = \"client_password\"/clientPassword = \"$CLIENT_SECRET\"/" \
  HealthSDK/GiniHealthSDKExample/GiniHealthSDKExample/CredentialsManager.swift

echo "Credentials and certificates setup completed successfully."