#!/usr/bin/env bash

if bluetoothctl show | grep -q "Powered: yes"; then
    connected=$(bluetoothctl devices Connected | wc -l)

    if [ "$connected" -gt 0 ]; then
        echo "$connected"
    else
        echo "On"
    fi
else
    echo "Off"
fi
