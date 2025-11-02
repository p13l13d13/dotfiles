#!/usr/bin/env python3
import json
import os
import subprocess
import sys
import time
from copy import deepcopy
from pathlib import Path

STATE_DIR = Path(os.path.expanduser("~/.cache"))
STATE_DIR.mkdir(parents=True, exist_ok=True)
STATE_FILE = STATE_DIR / "waybar_pomodoro_state.json"

WORK_DURATION = 30 * 60
BREAK_DURATION = 5 * 60
MIN_PHASE_DURATION = 1
NOTIFICATION_TIMEOUT_MS = 7000
FLASH_DURATION_SECONDS = 1.5

DEFAULT_STATE = {
    "phase": "work",  # work, break
    "status": "stopped",  # running, paused, stopped
    "start_time": None,
    "elapsed": 0,
    "completed_cycles": 0,
    "phase_duration": WORK_DURATION,
    "phase_changed_at": None,
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
    changed_at = data.get("phase_changed_at")
    if isinstance(changed_at, (int, float)) and changed_at > 0:
        merged["phase_changed_at"] = float(changed_at)
    else:
        merged["phase_changed_at"] = None
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
    previous_phase = state["phase"]
    if state["phase"] == "work":
        state["completed_cycles"] += 1
        state["phase"] = "break"
    else:
        state["phase"] = "work"
    state["phase_duration"] = get_default_duration(state["phase"])
    state["start_time"] = now
    state["elapsed"] = 0
    return state["phase"] != previous_phase


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
    phase = state.get("phase")
    if phase not in {"work", "break"}:
        phase = DEFAULT_STATE["phase"]
    duration = state.get("phase_duration")
    if not isinstance(duration, (int, float)) or duration <= 0:
        duration = get_default_duration(phase)
    duration = max(MIN_PHASE_DURATION, int(duration))
    state.clear()
    state.update(
        {
            "phase": phase,
            "status": "stopped",
            "start_time": None,
            "elapsed": 0,
            "completed_cycles": 0,
            "phase_duration": duration,
            "phase_changed_at": None,
        }
    )


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
            if advance_phase(state, now):
                apply_phase_change_effects(state)


def format_time(seconds):
    seconds = max(0, round(seconds))
    minutes, secs = divmod(seconds, 60)
    return f"{minutes:02}:{secs:02}"


def phase_label(phase):
    if phase == "work":
        return "Work"
    if phase == "break":
        return "Break"
    return phase.replace("_", " ").title()


def safe_run_command(command):
    try:
        result = subprocess.run(
            command,
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        return result.returncode == 0
    except FileNotFoundError:
        return False
    except Exception:
        return False


def send_notification(phase):
    title = "Pomodoro"
    message = f"Time for {phase_label(phase)}"
    safe_run_command(
        [
            "notify-send",
            "--app-name=Pomodoro",
            "-t",
            str(NOTIFICATION_TIMEOUT_MS),
            title,
            message,
        ]
    )


def play_sound():
    if safe_run_command(["canberra-gtk-play", "--id", "message-new-instant"]):
        return
    safe_run_command(
        ["paplay", "/usr/share/sounds/freedesktop/stereo/complete.oga"]
    )


def apply_phase_change_effects(state, event_time=None):
    now = event_time or time.time()
    state["phase_changed_at"] = now
    send_notification(state["phase"])
    play_sound()


def update_running_state(state, now):
    if state["status"] != "running" or state["start_time"] is None:
        return
    duration = get_phase_duration(state)
    elapsed = now - state["start_time"]
    phase_changed = False
    while elapsed >= duration:
        phase_changed = (
            advance_phase(state, now - (elapsed - duration)) or phase_changed
        )
        duration = get_phase_duration(state)
        elapsed = now - state["start_time"]
    state["elapsed"] = max(0, elapsed)
    if phase_changed:
        apply_phase_change_effects(state, event_time=now)


def output_state(state, now=None):
    phase = state["phase"]
    duration = get_phase_duration(state)
    now = now or time.time()
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
    changed_at = state.get("phase_changed_at")
    if isinstance(changed_at, (int, float)) and now - changed_at < FLASH_DURATION_SECONDS:
        classes.append("phase-transition")
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
    output_state(state, now=now)


if __name__ == "__main__":
    main()
