#!/usr/bin/env bash

# Cycle through available PipeWire sinks (audio outputs) using wpctl
# and set the next one as default. Shows a short desktop notification.

set -euo pipefail

notify() {
  local title="$1"; shift
  local body="$1"; shift || true
  # Short, unobtrusive popup
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -a "Waybar" -t 1500 "${title}" "${body}"
  fi
}

# Extract Sinks block using a sed range: from "Sinks:" to just before "Sources:".
extract_section() {
  local section="$1"
  case "$section" in
    Sinks)
      wpctl status | sed -n '/Sinks:/,/Sources:/p'
      ;;
    *)
      wpctl status
      ;;
  esac
}

status_out=$(wpctl status 2>/dev/null || true)
if [[ -z "$status_out" ]]; then
  notify "Audio Output" "wpctl not available"
  exit 1
fi

# Collect list of sink names only (no IDs)
# Example input lines:
#   " │      34. Family ... [vol: 0.75]"
#   " │  *   43. UACDemoV1.0 Analog Stereo [vol: 0.56]"
# Output: just the readable name without trailing volume brackets
mapfile -t sinks < <(
  extract_section "Sinks" \
  | sed -n 's/^.*[0-9]\+\.\s\+\(.*\)$/\1/p' \
  | sed -E 's/ \[vol:.*\]$//'
)

if (( ${#sinks[@]} == 0 )); then
  notify "Audio Output" "No sinks found"
  exit 0
fi

# Determine current default sink name (line with asterisk)
default_name=$(extract_section "Sinks" \
  | sed -n 's/^.*\*\s*[0-9]\+\.\s\+\(.*\)$/\1/p' \
  | sed -E 's/ \[vol:.*\]$//' \
  | head -n1)

# Build names array (already names only)
names=("${sinks[@]}")

# Find next index
next_idx=0
if [[ -n "${default_name:-}" ]]; then
  for i in "${!names[@]}"; do
    if [[ "${names[$i]}" == "$default_name" ]]; then
      next_idx=$(( (i + 1) % ${#names[@]} ))
      break
    fi
  done
fi

new_name="${names[$next_idx]}"

# Resolve numeric ID for the selected name from the Sinks section only now
new_id=$(extract_section "Sinks" | awk -v n="$new_name" '
  index($0, n) {
    if (match($0, /[0-9]+\./)) { print substr($0, RSTART, RLENGTH-1); exit }
  }
')
if [[ -z "${new_id:-}" ]]; then
  notify "Audio Output" "Failed to resolve ID for $new_name"
  exit 1
fi

if wpctl set-default "$new_id" >/dev/null 2>&1; then
  notify "Audio Output" "$new_name"
else
  notify "Audio Output" "Failed to switch"
  exit 1
fi
