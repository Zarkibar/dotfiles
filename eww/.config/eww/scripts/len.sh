#!/bin/bash
playerctl -p spotify metadata mpris:length | awk '{print $1/1000000}'
