#!/bin/bash

# name of the sink. execute pactl list sinks to get a list
SINKNAME="alsa_output.pci-0000_00_1b.0.analog-stereo"

# this is the worst
SINK=$(( $(pactl list sinks | grep "Name: " | grep -n "${SINKNAME}" | grep -o "^[[:digit:]]*") -1))

getvol() {
    echo $(pactl list sinks | grep "^[[:space:]]*Volume" | head -n $(( $SINK + 1 )) | tail -n 1 | grep -o "[[:digit:]]*%" | head -n 1 | cut -d "%" -f 1)
}

setvol() {
    if [[ $1 =~ [+-][0-9]+ ]] ; then
        oldvol="$(getvol)"
        echo "oldvol $oldvol"
        delta="$(echo "$1" | cut -c 2-)"
        echo "delta $delta"
        if [[ "$(echo "$1" | cut -c 1)" == "+" ]] ; then
            echo "+"
            newvol=$(( $oldvol + $delta ))
        else
            echo "-"
            newvol=$(( $oldvol - $delta ))
            echo $newvol
        fi
        if [[ $newvol -gt 100 ]]; then
            echo "capping at 100 percent"
            newvol=100
        fi
        if [[ $newvol -lt 0 ]]; then
            echo "capping at 0 percent"
            newvol=0
        fi
        echo "newvol $newvol"
    else
        newvol="$1"
    fi
    pactl set-sink-volume $SINKNAME $(( $newvol * 65536 / 100 ))
}

ismuted() {
    muted=$(pactl list sinks | grep "^[[:space:]]*Mute" | head -n $(( $SINK + 1 )) | tail -n 1 | cut -d " " -f 2)
    if [[ $muted == "no" ]]; then
        echo 0
    else
        echo 1
    fi
}

mute() {
    pactl set-sink-mute $SINK 1
}

unmute() {
    pactl set-sink-mute $SINK 0
}

mute-toggle() {
    pactl set-sink-mute $SINK toggle
}

status() {
    if [[ $(ismuted) == "1" ]] ; then
        echo "mute"
        return
    fi
    echo "$(getvol)%"
}

usage() {
    echo "Usage:"
    echo
    echo "$0 get-vol"
    echo "$0 set-vol VOL_PERC"
}

case "$1" in
    "get-vol")
        echo $(getvol)
        ;;
    "set-vol")
        if [[ -z "$2" ]] ; then
            usage
        else
            setvol "$2"
        fi
        hook="$3"
        ;;
    "mute")
        mute
        hook="$2"
        ;;
    "unmute")
        unmute
        hook="$2"
        ;;
    "mute-toggle")
        mute-toggle
        hook="$2"
        ;;
    "is-muted")
        echo $(ismuted)
        ;;
    "status")
        echo $(status)
        ;;
    *)
        usage
        ;;
esac

if [[ -n "$hook" ]] ; then
    echo "volume changed, executing hook: $hook"
    $hook
fi
