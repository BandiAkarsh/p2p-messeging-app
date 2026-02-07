#!/bin/bash
# Diagnostic script for flutter pub get issues

echo "=== Flutter Environment Check ==="
echo "Flutter path: $(which flutter)"
echo "Flutter version:"
flutter --version
echo ""

echo "=== Dart Version ==="
dart --version
echo ""

echo "=== Network Test ==="
echo "Testing pub.dev connection..."
curl -s -o /dev/null -w "%{http_code}" https://pub.dev
echo " (should be 200)"
echo ""

echo "=== Running flutter pub get with timeout ==="
cd apps/mobile

timeout 120 flutter pub get -v 2>&1 | tee /tmp/pub_get_log.txt | tail -100

echo ""
echo "=== Exit Code: $? ==="
echo ""
echo "If it shows '124', the command timed out (120 seconds)"
echo "Check full log at: /tmp/pub_get_log.txt"
