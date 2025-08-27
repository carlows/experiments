#!/bin/bash

# Usage: ./watch_ruby.sh <ruby_script>
if [ $# -eq 0 ]; then
    echo "Usage: $0 <ruby_script>"
    echo "Example: $0 01.rb"
    exit 1
fi

SCRIPT=$1

if [ ! -f "$SCRIPT" ]; then
    echo "Error: File '$SCRIPT' not found"
    exit 1
fi

echo "Watching $SCRIPT for changes. Press Ctrl+C to stop."
echo "Running initial execution..."
ruby "$SCRIPT"
echo "---"

fswatch -o "$SCRIPT" | while read f; do
    echo "File changed, running: ruby $SCRIPT"
    ruby "$SCRIPT"
    echo "---"
done
