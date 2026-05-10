#!/bin/bash

if pgrep -x wf-recorder >/dev/null; then
  echo '{"text":"⏺ REC","tooltip":"Screen recording is active","class":"recording"}'
else
  echo '{"text":"","tooltip":""}'
fi
