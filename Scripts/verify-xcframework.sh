#!/bin/bash
# Preflight validation for the built Qeen.xcframework, run BEFORE publishing to
# GitHub. Catches the classes of problem that otherwise only surface during App
# Store submission (ITMS-* rejections) — most importantly ITMS-90332, dangling
# symlinks baked into the framework.
#
# Usage:  ./Scripts/verify-xcframework.sh [path/to/Qeen.xcframework]
# Exit 0 = safe to publish; non-zero = do NOT publish.
set -uo pipefail

PKG_DIR="$(cd "$(dirname "$0")/.." && pwd)"
XCFW="${1:-$PKG_DIR/dist/Qeen.xcframework}"
SCHEME="Qeen"
fail=0

echo "▸ Verifying: $XCFW"

if [[ ! -d "$XCFW" ]]; then
  echo "  ✗ xcframework not found"
  exit 1
fi

# 1) ITMS-90332: no symbolic links anywhere in the xcframework. App Store rejects
#    symlinks inside frameworks (dangling OR valid). We flag every one.
links="$(find "$XCFW" -type l)"
if [[ -n "$links" ]]; then
  echo "  ✗ symbolic links found (ITMS-90332 risk):"
  echo "$links" | sed 's/^/      /'
  # Extra detail: which of them are dangling (resolve to a missing target).
  while IFS= read -r l; do
    [[ -e "$l" ]] || echo "      ↳ DANGLING: $l -> $(readlink "$l")"
  done <<< "$links"
  fail=1
else
  echo "  ✓ no symbolic links"
fi

# 2) Each slice has a real framework binary and a Swift module (so `import Qeen` works).
found_slice=0
for slice in "$XCFW"/*/; do
  fw="$slice$SCHEME.framework"
  [[ -d "$fw" ]] || continue
  found_slice=1
  name="$(basename "$slice")"
  if [[ ! -f "$fw/$SCHEME" ]]; then
    echo "  ✗ [$name] missing framework binary $SCHEME"; fail=1
  fi
  if [[ ! -d "$fw/Modules/$SCHEME.swiftmodule" ]]; then
    echo "  ✗ [$name] missing Modules/$SCHEME.swiftmodule (consumers can't import Qeen)"; fail=1
  fi
  # 3) Privacy manifest present (ITMS-91053).
  if [[ ! -f "$fw/PrivacyInfo.xcprivacy" ]]; then
    echo "  ✗ [$name] missing PrivacyInfo.xcprivacy (ITMS-91053 risk)"; fail=1
  fi
  # 4) Every .bundle is a real directory with an Info.plist (not a stray symlink/file).
  while IFS= read -r b; do
    [[ -z "$b" ]] && continue
    if [[ ! -d "$b" ]]; then
      echo "  ✗ [$name] bundle is not a directory: $(basename "$b")"; fail=1
    elif [[ ! -f "$b/Info.plist" ]]; then
      echo "  ✗ [$name] bundle missing Info.plist: $(basename "$b")"; fail=1
    fi
  done < <(find "$fw" -maxdepth 1 -name "*.bundle")
  [[ $fail -eq 0 ]] && echo "  ✓ [$name] binary + module + privacy manifest + bundles OK"
done

if [[ $found_slice -eq 0 ]]; then
  echo "  ✗ no $SCHEME.framework slices found in xcframework"; fail=1
fi

echo
if [[ $fail -eq 0 ]]; then
  echo "✅ PASS — safe to publish."
else
  echo "❌ FAIL — do NOT publish. Rebuild with ./Scripts/build-xcframework.sh and re-verify."
fi
exit $fail
