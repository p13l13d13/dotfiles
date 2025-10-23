#!/usr/bin/env bash

set -euo pipefail

# Prints a concise microphone status for Waybar custom module.
# - Shows a mic icon and optional MUTE indicator
# - Tooltip includes current default source name

get_default_source_name() {
  # Extract the human-readable default source name from wpctl status
  # Take the line with '*' in Sources section, strip leading decorations and trailing [vol: ...]
  local section
  section=$(wpctl status | sed -n '/Sources:/,/Filters:/p') || true
  if [[ -z "$section" ]]; then
    section=$(wpctl status | sed -n '/Sources:/,/Streams:/p') || true
  fi
  printf "%s\n" "$section" \
    | sed -n 's/^.*\*\s*[0-9]\+\.\s\+\(.*\)$/\1/p' \
    | sed -E 's/ \[vol:.*\]$//' \
    | head -n1
}

vol_line=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null || true)
if [[ -z "$vol_line" ]]; then
  echo ""  # show muted mic icon if status unavailable
  exit 0
fi

is_muted=0
if [[ "$vol_line" == *"[MUTED]"* ]]; then
  is_muted=1
fi

name=$(get_default_source_name)

# Icons:  (mic),  (mic-slash) from Font Awesome; fallback to text if font missing
if (( is_muted )); then
  # Nerd Font (Material Design) microphone-off; fallback handled by font stack
  icon="󰍭"
  label="$icon"
else
  # Nerd Font (Material Design) microphone
  icon="󰍬"
  label="$icon"
fi

# When Waybar uses return-type text + tooltip true, it shows stdout as label.
# Keep it minimal; the name is available if you want to switch to JSON later.
echo "$label"
