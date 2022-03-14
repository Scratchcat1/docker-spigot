#!/bin/bash
source /usr/local/bin/mc_util

function graceful_shutdown() {
    echo "SIGTERM received, stopping the server";
    stop;
    exit 0;
}

trap 'graceful_shutdown' INT TERM
trap 'graceful_shutdown' SIGQUIT

/usr/local/bin/my_runalways/00_minecraft_owner
/usr/local/bin/my_runalways/10_set_mc_version
/usr/local/bin/my_runalways/50_do_build_spigot
/usr/local/bin/my_runalways/85_fix_startsh
/usr/local/bin/my_runalways/90_eula
tmux new-session -d -s mcserver mc_start 
echo "Server console started in the tmux session."
mkfifo /tmp/tmuxpipe
tmux pipe-pane -o -t mcserver 'cat >> /tmp/tmuxpipe'
cat < /tmp/tmuxpipe & wait
# while true; do tail -f "$MC_DIR/logs/latest.log"; done & wait