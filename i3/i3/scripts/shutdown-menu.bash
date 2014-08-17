#!/usr/bin/env bash

options=(
"lock"
"logout"
"suspend"
"hibernate"
"reboot"
"shutdown")

i=1
output=$(
for option in "${options[@]}"; do
    echo "($i) $option"
    (( i++ ))
done | dmenu -fn 'DejaVu Sans Mono:size=11' -b -i -l 10 -p '>' -nb '#222222' -nf '#ffffff' -sb '#e16b40' -sf '#000000' -w 200 -name 'shutdown-menu')

[[ "$output" ]] && "$(dirname "$0")"/i3exit.bash "${output#(*) }"
