#!/usr/bin/env bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR" || exit 1

SESSION_NAME="resume-edit"
SOCKET_PATH="$HOME/.config/herdr/sessions/$SESSION_NAME/herdr.sock"

if ! command -v herdr >/dev/null 2>&1; then
    echo "herdr is not installed. Run the pieces manually instead:" >&2
    echo "  nvim Resume.tex" >&2
    echo "  ./render_resume.sh" >&2
    echo "  opencode --continue" >&2
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required to parse herdr's output." >&2
    exit 1
fi

session_running() {
    herdr session list --json 2>/dev/null \
        | jq -e --arg n "$SESSION_NAME" '.sessions[] | select(.name == $n and .running == true)' >/dev/null 2>&1
}

# Use a dedicated named session instead of the default one, so this doesn't
# clutter (or depend on) whatever the default herdr session is doing.
just_started=0
if ! session_running; then
    just_started=1
    echo "Starting dedicated herdr session '$SESSION_NAME'..."
    setsid nohup herdr --session "$SESSION_NAME" server >/dev/null 2>&1 < /dev/null &
    disown
    for _ in $(seq 1 20); do
        session_running && break
        sleep 0.5
    done
    if ! session_running; then
        echo "Failed to start herdr session '$SESSION_NAME'." >&2
        exit 1
    fi
fi

export HERDR_SOCKET_PATH="$SOCKET_PATH"

# A brand new (or freshly deleted) session has no workspace at all yet.
workspace_id=$(herdr workspace list 2>/dev/null | jq -r '.result.workspaces[0].workspace_id // empty')
if [ -z "$workspace_id" ]; then
    workspace_id=$(herdr workspace create --cwd "$DIR" --label "Resume" --focus 2>/dev/null | jq -r '.result.workspace.workspace_id // empty')
fi
if [ -z "$workspace_id" ]; then
    echo "Failed to create herdr workspace." >&2
    exit 1
fi

if [ "$just_started" -eq 1 ]; then
    # herdr restores the previous tab layout on startup, but the processes in
    # those tabs (nvim/opencode/render_resume.sh) didn't survive the restart -
    # they're just idle shells now. Clear out any stale "resume-edit" tabs
    # left over from before, so we start from a real, live tab below.
    for stale_tab in $(herdr tab list 2>/dev/null | jq -r --arg l "$SESSION_NAME" '.result.tabs[] | select(.label == $l) | .tab_id'); do
        herdr tab close "$stale_tab" >/dev/null 2>&1
    done
else
    # The session was already running, so a matching tab (if any) is a live
    # editing session from an earlier run of this script - reuse it instead
    # of creating a duplicate.
    existing_tab_id=$(herdr tab list 2>/dev/null | jq -r --arg l "$SESSION_NAME" '.result.tabs[] | select(.label == $l) | .tab_id' | head -n 1)

    if [ -n "$existing_tab_id" ] && [ "$existing_tab_id" != "null" ]; then
        herdr tab focus "$existing_tab_id" >/dev/null
        echo "Reusing existing '$SESSION_NAME' tab."
        exec env -u HERDR_ENV -u HERDR_PANE_ID -u HERDR_TAB_ID -u HERDR_SOCKET_PATH -u HERDR_WORKSPACE_ID \
            herdr session attach "$SESSION_NAME"
    fi
fi

# 1. Create a tab whose root pane becomes the nvim editor
tab_json=$(herdr tab create --workspace "$workspace_id" --cwd "$DIR" --label "$SESSION_NAME" --focus)
editor_pane=$(jq -r '.result.root_pane.pane_id' <<<"$tab_json")
tab_id=$(jq -r '.result.tab.tab_id' <<<"$tab_json")

if [ -z "$editor_pane" ] || [ "$editor_pane" = "null" ]; then
    echo "Failed to create herdr tab." >&2
    exit 1
fi

herdr pane send-text "$editor_pane" "nvim Resume.tex"
herdr pane send-keys "$editor_pane" Enter

# 2. Split right for the AI agent (full height)
agent_pane=$(herdr pane split "$editor_pane" --direction right --cwd "$DIR" --no-focus | jq -r '.result.pane.pane_id')
herdr pane send-text "$agent_pane" "opencode --continue"
herdr pane send-keys "$agent_pane" Enter

# 3. Split the editor pane down (small strip) for the render control panel.
#    Note: herdr's --ratio is the share kept by the *existing* pane, so 0.85
#    leaves the editor with the majority of the space and the new pane 15%.
render_pane=$(herdr pane split "$editor_pane" --direction down --ratio 0.85 --cwd "$DIR" --no-focus | jq -r '.result.pane.pane_id')
herdr pane send-text "$render_pane" "./render_resume.sh"
herdr pane send-keys "$render_pane" Enter

# 4. Focus back on the editor tab
herdr tab focus "$tab_id"

# 5. Attach to the session in the terminal we were run from. Unset the
#    HERDR_* vars this terminal may have inherited so herdr doesn't refuse to
#    attach on the assumption that this would be a nested session.
exec env -u HERDR_ENV -u HERDR_PANE_ID -u HERDR_TAB_ID -u HERDR_SOCKET_PATH -u HERDR_WORKSPACE_ID \
    herdr session attach "$SESSION_NAME"
