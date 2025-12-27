#!/bin/bash

# Script to generate a release keystore for Android app signing
# This keystore is REQUIRED for Google Play Store uploads
# 
# IMPORTANT: 
# - Keep this keystore file secure and backed up
# - If you lose this keystore, you CANNOT update your app on Play Store
# - Never commit the keystore file to version control
# - Store passwords securely (consider using a password manager)

set -e

KEYSTORE_FILE="android/upload-keystore.jks"
KEY_ALIAS="upload"
VALIDITY_YEARS=25

echo "=========================================="
echo "Android Release Keystore Generator"
echo "=========================================="
echo ""
echo "This script will generate a keystore file for signing your Android app."
echo "The keystore will be saved to: ${KEYSTORE_FILE}"
echo ""
echo "IMPORTANT REMINDERS:"
echo "  - You will be prompted for a store password and key password"
echo "  - Remember these passwords - you'll need them for future builds"
echo "  - Back up the keystore file securely"
echo "  - Never commit the keystore to git"
echo ""

# Check if keystore already exists
if [ -f "${KEYSTORE_FILE}" ]; then
    echo "WARNING: Keystore file already exists at ${KEYSTORE_FILE}"
    read -p "Do you want to overwrite it? (yes/no): " overwrite
    if [ "$overwrite" != "yes" ]; then
        echo "Aborted. Keystore generation cancelled."
        exit 1
    fi
    echo ""
fi

# Prompt for keystore information
echo "Please provide the following information:"
echo ""

read -sp "Enter store password (min 6 characters): " STORE_PASSWORD
echo ""
if [ ${#STORE_PASSWORD} -lt 6 ]; then
    echo "Error: Store password must be at least 6 characters"
    exit 1
fi

read -sp "Enter key password (min 6 characters, can be same as store password): " KEY_PASSWORD
echo ""
if [ ${#KEY_PASSWORD} -lt 6 ]; then
    echo "Error: Key password must be at least 6 characters"
    exit 1
fi

read -p "Enter your name or organization name: " NAME
if [ -z "$NAME" ]; then
    echo "Error: Name cannot be empty"
    exit 1
fi

read -p "Enter organizational unit (e.g., Development): " OU
OU=${OU:-Development}

read -p "Enter organization (e.g., Elifiner): " ORG
ORG=${ORG:-Elifiner}

read -p "Enter city: " CITY
CITY=${CITY:-""}

read -p "Enter state/province: " STATE
STATE=${STATE:-""}

read -p "Enter country code (2 letters, e.g., US): " COUNTRY
COUNTRY=${COUNTRY:-US}

# Build distinguished name
DN="CN=${NAME}"
if [ -n "$OU" ]; then
    DN="${DN}, OU=${OU}"
fi
if [ -n "$ORG" ]; then
    DN="${DN}, O=${ORG}"
fi
if [ -n "$CITY" ]; then
    DN="${DN}, L=${CITY}"
fi
if [ -n "$STATE" ]; then
    DN="${DN}, ST=${STATE}"
fi
DN="${DN}, C=${COUNTRY}"

echo ""
echo "Generating keystore..."
echo ""

# Generate keystore
keytool -genkey -v \
    -keystore "${KEYSTORE_FILE}" \
    -alias "${KEY_ALIAS}" \
    -keyalg RSA \
    -keysize 2048 \
    -validity $((VALIDITY_YEARS * 365)) \
    -storepass "${STORE_PASSWORD}" \
    -keypass "${KEY_PASSWORD}" \
    -dname "${DN}"

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "Keystore generated successfully!"
    echo "=========================================="
    echo ""
    echo "Keystore file: ${KEYSTORE_FILE}"
    echo "Key alias: ${KEY_ALIAS}"
    echo ""
    echo "NEXT STEPS:"
    echo "1. Update android/key.properties with your passwords:"
    echo "   storePassword=${STORE_PASSWORD}"
    echo "   keyPassword=${KEY_PASSWORD}"
    echo "   keyAlias=${KEY_ALIAS}"
    echo "   storeFile=../upload-keystore.jks"
    echo ""
    echo "2. IMPORTANT: Back up ${KEYSTORE_FILE} securely"
    echo "   - Store in a secure location (password manager, encrypted drive)"
    echo "   - You'll need this file for ALL future app updates"
    echo ""
    echo "3. Verify the keystore was created:"
    echo "   keytool -list -v -keystore ${KEYSTORE_FILE} -alias ${KEY_ALIAS}"
    echo ""
else
    echo ""
    echo "Error: Failed to generate keystore"
    exit 1
fi

