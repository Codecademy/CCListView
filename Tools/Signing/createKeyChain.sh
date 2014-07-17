#!/bin/sh
security create-keychain -p travis ios-build.keychain
security import ./Tools/Signing/AppleWWDRCA.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import ./Tools/Signing/Distribution\ Certificate.cer -k ~/Library/Keychains/ios-build.keychain -T /usr/bin/codesign
security import ./Tools/Signing/Distribution\ Certificate.p12 -k ~/Library/Keychains/ios-build.keychain -P $KEY_PASSWORD -T /usr/bin/codesign
security default-keychain -s ios-build.keychain
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp "./$PROFILE_NAME.mobileprovision" ~/Library/MobileDevice/Provisioning\ Profiles/