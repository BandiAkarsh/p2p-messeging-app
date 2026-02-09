#!/bin/bash

# Android Build Test Script
# This script simulates the CI build process locally to catch errors before pushing

echo "==================================="
echo "Android Build Test Script"
echo "==================================="
echo ""

# Check if Java 17 is installed
echo "Checking Java version..."
java -version 2>&1 | head -n 1

# Set JAVA_HOME if not set
if [ -z "$JAVA_HOME" ]; then
    echo "JAVA_HOME not set. Attempting to find Java 17..."
    if command -v java &> /dev/null; then
        export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
        echo "Set JAVA_HOME to: $JAVA_HOME"
    fi
fi

echo ""
echo "JAVA_HOME: $JAVA_HOME"
echo ""

# Navigate to Android directory
cd apps/mobile/android

# Clean previous builds
echo "Cleaning previous builds..."
./gradlew clean

# Kill gradle daemon
echo "Killing Gradle daemon..."
./gradlew --stop 2>/dev/null || true

# Clear gradle cache (optional - removes cached dependencies)
echo "Clearing Gradle cache..."
rm -rf ~/.gradle/caches/

# Setup Gradle properties for CI-like environment
echo "Setting up Gradle properties..."
echo "org.gradle.java.home=$JAVA_HOME" >> gradle.properties
echo "org.gradle.daemon=false" >> gradle.properties
echo "org.gradle.jvmargs=-Xmx4g" >> gradle.properties

# Build debug APK first (faster than release)
echo ""
echo "==================================="
echo "Building Debug APK..."
echo "==================================="
./gradlew assembleDebug

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Debug build successful!"
    echo ""
    
    # Now try release build
    echo "==================================="
    echo "Building Release APK..."
    echo "==================================="
    ./gradlew assembleRelease
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Release build successful!"
        echo "APK location: apps/mobile/build/app/outputs/flutter-apk/app-release.apk"
        exit 0
    else
        echo ""
        echo "❌ Release build failed!"
        exit 1
    fi
else
    echo ""
    echo "❌ Debug build failed!"
    exit 1
fi