#!/bin/bash

# Command or application to launch
APP="../kping-go/kping 192.168.160.122:30450"  # <-- Replace this with your command

# Number of times to launch
COUNT=100

for ((i=1; i<=COUNT; i++)); do
    echo "Launching $APP ($i/$COUNT)..."
    $APP > /dev/null 2>&1 &   # The '&' runs it in the background
    sleep 1  # Optional: wait 1 second between launches
done

echo "All $COUNT instances of $APP launched."
