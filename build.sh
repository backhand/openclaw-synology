#!/bin/bash
set -euo pipefail

# Build Synology SPK for OpenClaw
# Modeled after standard Synology package structure and spksrc examples

PKG_NAME="openclaw"
PKG_VER=$(grep '^version=' INFO | cut -d'"' -f2)
SPK_FILE="${PKG_NAME}-${PKG_VER}.spk"

# Clean previous builds
rm -f package.tgz "${SPK_FILE}"

# Create package.tgz from package/ dir
tar -czf package.tgz -C package .

# Create final SPK (includes INFO, icons, conf, scripts, package.tgz)
tar -cf "${SPK_FILE}" INFO PACKAGE_ICON* conf/ scripts/ package.tgz

echo "Built ${SPK_FILE}"
