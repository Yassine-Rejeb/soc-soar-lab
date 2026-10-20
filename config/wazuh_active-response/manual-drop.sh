#!/bin/bash
read INPUT
IPS=$(echo "$INPUT" | jq -r '.parameters.extra_args[0]' | tr ',' ' ')
DURATION=$(echo "$INPUT" | jq -r '.parameters.extra_args[1]')

LOG_FILE="/var/ossec/logs/manual-drop.log"

for IP in $IPS; do
  echo "$(date) - Blocking $IP for $DURATION seconds" >> $LOG_FILE
  iptables -A INPUT -s "$IP" -j DROP

  # Run unblock in background
  (
    sleep "$DURATION"
    iptables -D INPUT -s "$IP" -j DROP
    echo "$(date) - Unblocked $IP after $DURATION seconds" >> $LOG_FILE
  ) &
done

exit 0

