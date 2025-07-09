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

# Autostart hyprland on login 
if test -z "$DISPLAY" -a (tty) = "/dev/tty1"
    exec Hyprland
end
