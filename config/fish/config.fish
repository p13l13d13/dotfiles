if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -g fish_key_bindings fish_vi_key_bindings
set fish_vi_force_cursor 1
set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore
set -x EDITOR nvim
set -x ELECTRON_OZONE_PLATFORM_HINT auto
fzf --fish | source
set theme_color_scheme "gruvbox"
set -x BOTHOST 91.99.204.42
zoxide init fish | source

if status --is-interactive
    # On first login after boot, starts ssh-agent and prompts once for your passphrase.
    # On subsequent shells, it simply reuses the already-running agent.
    eval (keychain --quiet --timeout 2880 --eval $HOME/.ssh/id_ed25519)
end

function __fish_auto_venv --on-variable PWD
    # 1. Walk upward from $PWD until / looking for .venv or venv
    set -l dir $PWD
    set -e __auto_new_venv
    while test "$dir" != /
        for candidate in .venv venv
            if test -d "$dir/$candidate"
                set -g __auto_new_venv "$dir/$candidate"
                break
            end
        end
        test -n "$__auto_new_venv"; and break
        set dir (dirname $dir)
    end

    # 2. Decide whether to (de)activate
    if test -n "$__auto_new_venv"
        # Found a venv somewhere above
        if not set -q VIRTUAL_ENV; or test "$VIRTUAL_ENV" != "$__auto_new_venv"
            # Different venv (or none) -> switch
            if functions -q deactivate; and set -q VIRTUAL_ENV
                deactivate    # clean up current venv first
            end
            # Activate the new one.  Works for venv or virtualenv.
            if test -f "$__auto_new_venv/bin/activate.fish"
                source "$__auto_new_venv/bin/activate.fish"
            else if test -f "$__auto_new_venv/bin/activate"
                # fall back to POSIX activate if fish one is missing
                source "$__auto_new_venv/bin/activate"
            end
        end
    else
        # No venv found → deactivate any active one
        if functions -q deactivate; and set -q VIRTUAL_ENV
            deactivate
        end
    end
end

# Autostart hyprland on login 
# if test -z "$DISPLAY" -a (tty) = "/dev/tty1"
#     exec Hyprland
# end

# Created by `pipx` on 2025-10-02 09:24:51
set PATH $PATH /home/gulakov/.local/bin
