#!/bin/bash
if pgrep -x xvkbd > /dev/null; then
    killall xvkbd
else
    xvkbd -geometry 500x200 -once &
fi
