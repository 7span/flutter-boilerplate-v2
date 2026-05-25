#!/usr/bin/env bash
#
# Non-interactive variant of scripts/project_setup.sh.
# Accepts flags so an automation agent can customise app name, Android/iOS
# package identifier and launcher icon without stdin prompts.
#
# All flags are optional. Omitted flags leave the corresponding value unchanged.

set -euo pipefail

APP_NAME=""
PACKAGE_NAME=""
LOGO_PATH=""

usage() {
  cat <<'USAGE'
Usage: agent_setup.sh [options]

Options:
  --app-name <name>   Replace the Android appLabel "Core App" (and its QA/Staging
                      variants) in apps/app_core/android/app/build.gradle.kts.
  --package  <id>     Change the Android/iOS package identifier using
                      `dart run change_app_package_name:main <id>`. Note: Firebase
                      configuration must be re-uploaded manually afterwards.
  --logo     <path>   Copy <path> to packages/app_ui/assets/images/logo.png and
                      regenerate launcher icons with flutter_launcher_icons.
  -h, --help          Show this help.

Run from the repository root.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --app-name)   APP_NAME="${2:-}"; shift 2 ;;
    --app-name=*) APP_NAME="${1#*=}"; shift ;;
    --package)    PACKAGE_NAME="${2:-}"; shift 2 ;;
    --package=*)  PACKAGE_NAME="${1#*=}"; shift ;;
    --logo)       LOGO_PATH="${2:-}"; shift 2 ;;
    --logo=*)     LOGO_PATH="${1#*=}"; shift ;;
    -h|--help)    usage; exit 0 ;;
    *)            echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$APP_NAME" && -z "$PACKAGE_NAME" && -z "$LOGO_PATH" ]]; then
  echo "Nothing to do. Pass at least one of --app-name, --package or --logo." >&2
  usage
  exit 1
fi

# `sed -i` differs between GNU (Linux) and BSD (macOS). Detect once.
if sed --version >/dev/null 2>&1; then
  sed_inplace() { sed -i "$@"; }
else
  sed_inplace() { sed -i '' "$@"; }
fi

GRADLE_FILE="apps/app_core/android/app/build.gradle.kts"

if [[ -n "$APP_NAME" ]]; then
  if [[ ! -f "$GRADLE_FILE" ]]; then
    echo "Error: $GRADLE_FILE not found. Run this script from the repo root." >&2
    exit 1
  fi
  sed_inplace "s/manifestPlaceholders\[\"appLabel\"\] = \"Core App\"/manifestPlaceholders[\"appLabel\"] = \"${APP_NAME}\"/g" "$GRADLE_FILE"
  sed_inplace "s/manifestPlaceholders\[\"appLabel\"\] = \"Core App QA\"/manifestPlaceholders[\"appLabel\"] = \"${APP_NAME} QA\"/g" "$GRADLE_FILE"
  sed_inplace "s/manifestPlaceholders\[\"appLabel\"\] = \"Core App Staging\"/manifestPlaceholders[\"appLabel\"] = \"${APP_NAME} Staging\"/g" "$GRADLE_FILE"
  echo "✓ appLabel updated to '${APP_NAME}' in ${GRADLE_FILE}"
fi

if [[ -n "$PACKAGE_NAME" ]]; then
  pushd apps/app_core >/dev/null
  dart run change_app_package_name:main "$PACKAGE_NAME"
  popd >/dev/null
  echo "✓ Package identifier changed to '${PACKAGE_NAME}'"
  echo "  ⚠ Firebase config (google-services.json / GoogleService-Info.plist) must be re-uploaded manually."
fi

if [[ -n "$LOGO_PATH" ]]; then
  if [[ ! -f "$LOGO_PATH" ]]; then
    echo "Error: logo file not found at '$LOGO_PATH'." >&2
    exit 1
  fi
  cp "$LOGO_PATH" packages/app_ui/assets/images/logo.png
  pushd apps/app_core >/dev/null
  dart run flutter_launcher_icons
  popd >/dev/null
  echo "✓ Launcher icon regenerated from '${LOGO_PATH}'"
fi

echo "Done."
