#!/bin/bash
# very-basic Wazuh active-response: extract PID from alert.all_fields.full_log and kill it

read INPUT
RAW_LOG=$(echo "$INPUT" | jq -r '.alert.all_fields.full_log // empty')

LOG="/var/ossec/logs/manual-kill.log"

if [ -z "$RAW_LOG" ]; then
  echo "$(date) - No full_log field found" >> "$LOG"
  exit 1
fi

# extract numeric PID after 'pid='
PID=$(echo "$RAW_LOG" | grep -oP 'pid=\K[0-9]+')

echo "$(date) - Extracted PID=${PID} from log" >> "$LOG"

if [ -z "$PID" ]; then
  echo "$(date) - No PID pattern found in full_log" >> "$LOG"
  exit 1
fi

if kill -9 "$PID" 2>/dev/null; then
  echo "$(date) - Killed PID $PID" >> "$LOG"
  exit 0
else
  echo "$(date) - Failed to kill PID $PID" >> "$LOG"
  exit 1
fi

