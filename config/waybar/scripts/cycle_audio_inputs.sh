#!/usr/bin/env bash

# Cycle through available PipeWire sources (audio inputs) using wpctl
# and set the next one as default. Shows a short desktop notification.

set -euo pipefail

notify() {
  local title="$1"; shift
  local body="$1"; shift || true
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -a "Waybar" -t 1500 "${title}" "${body}"
  fi
}

# Extract Sources block using a sed range.
extract_section() {
  local section="$1"
  case "$section" in
    Sources)
      local out
      out=$(wpctl status | sed -n '/Sources:/,/Filters:/p') || true
      if [[ -z "$out" ]]; then
        wpctl status | sed -n '/Sources:/,/Streams:/p'
      else
        printf "%s\n" "$out"
      fi
      ;;
    *)
      wpctl status
      ;;
  esac
}

status_out=$(wpctl status 2>/dev/null || true)
if [[ -z "$status_out" ]]; then
  notify "Audio Input" "wpctl not available"
  exit 1
fi

# Collect list of source names only (no IDs)
mapfile -t sources < <(
  extract_section "Sources" \
  | sed -n 's/^.*[0-9]\+\.\s\+\(.*\)$/\1/p' \
  | sed -E 's/ \[vol:.*\]$//'
)

if (( ${#sources[@]} == 0 )); then
  notify "Audio Input" "No sources found"
  exit 0
fi

# Determine current default source name
default_name=$(extract_section "Sources" \
  | sed -n 's/^.*\*\s*[0-9]\+\.\s\+\(.*\)$/\1/p' \
  | sed -E 's/ \[vol:.*\]$//' \
  | head -n1)

names=("${sources[@]}")

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

# Resolve numeric ID for the selected name from the Sources section only now
new_id=$(extract_section "Sources" | awk -v n="$new_name" '
  index($0, n) {
    if (match($0, /[0-9]+\./)) { print substr($0, RSTART, RLENGTH-1); exit }
  }
')
if [[ -z "${new_id:-}" ]]; then
  notify "Audio Input" "Failed to resolve ID for $new_name"
  exit 1
fi

if wpctl set-default "$new_id" >/dev/null 2>&1; then
  notify "Audio Input" "$new_name"
else
  notify "Audio Input" "Failed to switch"
  exit 1
fi
