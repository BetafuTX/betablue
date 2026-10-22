# bazzite-niri helpers, available via `ujust <recipe>`

# Generate a niri config with Dank Material Shell keybinds, layout and theming
setup-niri-dms:
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -f "$HOME/.config/niri/config.kdl" ]; then
        backup="$HOME/.config/niri/config.kdl.bak-$(date +%Y%m%d-%H%M%S)"
        cp "$HOME/.config/niri/config.kdl" "$backup"
        echo "Backed up existing niri config to $backup"
    fi
    dms setup
    echo
    echo "Done. Log out and pick 'Niri' at the login screen, or press Mod+Shift+E to restart niri if you're in it."

# Check that niri, DMS and their helpers are installed and healthy
niri-dms-doctor:
    #!/usr/bin/env bash
    set -uo pipefail
    echo "niri: $(niri --version 2>/dev/null || echo 'MISSING')"
    echo "dms:  $(dms version 2>/dev/null || echo 'installed' )"
    systemctl --user cat niri.service >/dev/null 2>&1 && echo "niri.service: present" || echo "niri.service: MISSING"
    systemctl --user show -p Wants niri.service 2>/dev/null
    dms doctor || true

# Stop DMS from auto-starting with niri (undo with `ujust enable-dms-autostart`)
disable-dms-autostart:
    systemctl --user mask dms.service
    echo "DMS will no longer start with niri."

# Re-enable DMS auto-start with niri
enable-dms-autostart:
    systemctl --user unmask dms.service
    echo "DMS will start with niri on next login."
