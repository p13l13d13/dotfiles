#!/usr/bin/env python3
import json
import os
import sys
import time
from copy import deepcopy
from pathlib import Path

STATE_DIR = Path(os.path.expanduser("~/.cache"))
STATE_DIR.mkdir(parents=True, exist_ok=True)
STATE_FILE = STATE_DIR / "waybar_pomodoro_state.json"

WORK_DURATION = 30 * 60
BREAK_DURATION = 5 * 60
MIN_PHASE_DURATION = 60

DEFAULT_STATE = {
    "phase": "work",  # work, break
    "status": "stopped",  # running, paused, stopped
    "start_time": None,
    "elapsed": 0,
    "completed_cycles": 0,
    "phase_duration": WORK_DURATION,
}


def get_default_duration(phase):
    if phase == "work":
        return WORK_DURATION
    return BREAK_DURATION


def load_state():
    if not STATE_FILE.exists():
        return deepcopy(DEFAULT_STATE)
    try:
        with STATE_FILE.open("r", encoding="utf-8") as fh:
            data = json.load(fh)
    except (json.JSONDecodeError, OSError):
        return deepcopy(DEFAULT_STATE)
    merged = deepcopy(DEFAULT_STATE)
    merged.update({k: data.get(k, v) for k, v in DEFAULT_STATE.items()})
    if "completed_cycles" not in data and "completed_work_sessions" in data:
        merged["completed_cycles"] = data["completed_work_sessions"]
    if merged["phase"] in {"short_break", "long_break"}:
        merged["phase"] = "break"
    duration = data.get("phase_duration", merged["phase_duration"])
    if not isinstance(duration, (int, float)) or duration <= 0:
        duration = get_default_duration(merged["phase"])
    merged["phase_duration"] = max(MIN_PHASE_DURATION, int(duration))
    merged["elapsed"] = max(0, min(merged.get("elapsed", 0), merged["phase_duration"]))
    return merged


def save_state(state):
    with STATE_FILE.open("w", encoding="utf-8") as fh:
        json.dump(state, fh)


def ensure_phase_duration(state):
    default = get_default_duration(state["phase"])
    duration = state.get("phase_duration", default)
    if not isinstance(duration, (int, float)) or duration <= 0:
        duration = default
    duration = max(MIN_PHASE_DURATION, int(duration))
    state["phase_duration"] = duration
    return duration


def get_phase_duration(state):
    return ensure_phase_duration(state)


def advance_phase(state, now):
    if state["phase"] == "work":
        state["completed_cycles"] += 1
        state["phase"] = "break"
    else:
        state["phase"] = "work"
    state["phase_duration"] = get_default_duration(state["phase"])
    state["start_time"] = now
    state["elapsed"] = 0


def toggle(state):
    now = time.time()
    duration = get_phase_duration(state)
    if state["status"] == "running":
        elapsed = max(0, min(duration, now - (state["start_time"] or now)))
        state["elapsed"] = elapsed
        state["status"] = "paused"
        state["start_time"] = None
    else:
        # when stopped, reset elapsed to start a fresh phase
        if state["status"] == "stopped":
            state["elapsed"] = 0
        state["status"] = "running"
        state["start_time"] = now - state.get("elapsed", 0)


def reset(state):
    state.clear()
    state.update(deepcopy(DEFAULT_STATE))


def adjust_duration(state, delta_seconds):
    ensure_phase_duration(state)
    now = time.time()
    if state["status"] == "running" and state["start_time"] is not None:
        state["elapsed"] = max(0, now - state["start_time"])
    duration = state["phase_duration"]
    new_duration = max(MIN_PHASE_DURATION, duration + delta_seconds)
    state["phase_duration"] = new_duration
    state["elapsed"] = min(state["elapsed"], new_duration)
    if state["status"] == "running":
        state["start_time"] = now - state["elapsed"]
        if state["elapsed"] >= new_duration:
            advance_phase(state, now)


def format_time(seconds):
    seconds = max(0, int(seconds))
    minutes, secs = divmod(seconds, 60)
    return f"{minutes:02}:{secs:02}"


def phase_label(phase):
    if phase == "work":
        return "Work"
    if phase == "break":
        return "Break"
    return phase.replace("_", " ").title()


def update_running_state(state, now):
    if state["status"] != "running" or state["start_time"] is None:
        return
    duration = get_phase_duration(state)
    elapsed = now - state["start_time"]
    while elapsed >= duration:
        advance_phase(state, now - (elapsed - duration))
        duration = get_phase_duration(state)
        elapsed = now - state["start_time"]
    state["elapsed"] = max(0, elapsed)


def output_state(state):
    phase = state["phase"]
    duration = get_phase_duration(state)
    if state["status"] == "running":
        remaining = duration - state["elapsed"]
    elif state["status"] == "paused":
        remaining = duration - state["elapsed"]
    else:
        remaining = duration

    segments = [f"| {format_time(remaining)}"]
    if state["status"] == "paused":
        segments.append("⏸")

    text = f" {' '.join(segments)} "
    tooltip_lines = [
        f"Phase: {phase_label(phase)}",
        f"Status: {state['status']}",
        f"Completed cycles: {state['completed_cycles']}",
        f"Duration: {format_time(duration)}",
    ]
    classes = [phase, state["status"]]
    print(
        json.dumps(
            {
                "text": text,
                "tooltip": "\n".join(tooltip_lines),
                "class": classes,
            }
        )
    )


def main():
    state = load_state()
    if len(sys.argv) > 1:
        command = sys.argv[1]
        if command == "toggle":
            toggle(state)
        elif command == "reset":
            reset(state)
        elif command == "increase":
            adjust_duration(state, 5 * 60)
        elif command == "decrease":
            adjust_duration(state, -5 * 60)
        save_state(state)
        return

    now = time.time()
    update_running_state(state, now)
    save_state(state)
    output_state(state)


if __name__ == "__main__":
    main()
