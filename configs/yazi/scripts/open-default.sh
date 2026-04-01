#!/bin/bash
# Open file with the system default app (macOS/Linux).

if command -v open >/dev/null 2>&1; then
    open "$@"
    exit 0
fi

if command -v xdg-open >/dev/null 2>&1; then
    xdg-open "$@"
    exit 0
fi

if command -v gio >/dev/null 2>&1; then
    gio open "$@"
    exit 0
fi

echo "No system opener found (open/xdg-open/gio)." >&2
exit 1
