#!/bin/bash
# Open file in $EDITOR, with Zellij floating pane support

EDITOR_CMD="${EDITOR:-nvim}"

if [ -n "$ZELLIJ" ]; then
    # Inside Zellij: open in 90% floating pane
    zellij run --floating --close-on-exit --x 5% --y 5% --width 90% --height 90% -- $EDITOR_CMD "$@"
else
    # Outside Zellij: open directly
    $EDITOR_CMD "$@"
fi
