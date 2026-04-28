#!/bin/bash

DIR="/home/nate/Documents/Resume"
cd "$DIR" || exit 1

SESSION="resume-edit"

# 1. Create the session and start nvim
tmux new-session -d -s "$SESSION" -c "$DIR"
tmux send-keys -t "$SESSION" "nvim Resume.tex" C-m

# 2. Split horizontally to create the right pane
tmux split-window -h -t "$SESSION" -c "$DIR"

# Now we have:
# Pane 1: Left (nvim)
# Pane 2: Right (empty)

# 3. Select left pane and split vertically to create the bottom pane
tmux select-pane -t 1
tmux split-window -v -t "$SESSION" -p 15 -c "$DIR"

# Now we have:
# Pane 1: Top-left (nvim)
# Pane 2: Right (empty)
# Pane 3: Bottom-left (empty)

# 4. In the right pane (pane 2), run the render script
tmux select-pane -t 2
tmux send-keys -t 2 "./render_resume.sh $SESSION" C-m

# 5. In the bottom pane (pane 3), run pi --continue
tmux select-pane -t 3
tmux send-keys -t 3 "pi --continue" C-m

# 6. Focus back to the editor (pane 1)
tmux select-pane -t 1

# 7. Attach to the session
tmux attach-session -t "$SESSION"
