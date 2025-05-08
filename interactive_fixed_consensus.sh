#!/bin/bash

# Tor Consensus Snapshot Downloader & Analyzer
# Developed By Soham Datta

# ASCII Art Header
echo "+----------------------------------------------------------------+";
echo "|                                                                |";
echo "| _____             ____                                         |";
echo "||_   _|__  _ __   / ___|___  _ __  ___  ___ _ __  ___ _   _ ___ |";
echo "|  | |/ _ \| '__| | |   / _ \| '_ \/ __|/ _ \ '_ \/ __| | | / __||";
echo "|  | | (_) | |    | |__| (_) | | | \__ \  __/ | | \__ \ |_| \__ \|";
echo "|  |_|\___/|_|     \____\___/|_| |_|___/\___|_| |_|___/\__,_|___/|";
echo "|                                                                |";
echo "+----------------------------------------------------------------+";
cat << "EOF"

█▀▄ █▀▀ █░█ █▀▀ █░░ █▀█ █▀█ █▀▀ █▀▄   █▄▄ █▄█   █▀ █▀█ █░█ ▄▀█ █▀▄▀█   █▀▄ ▄▀█ ▀█▀ ▀█▀ ▄▀█
█▄▀ ██▄ ▀▄▀ ██▄ █▄▄ █▄█ █▀▀ ██▄ █▄▀   █▄█ ░█░   ▄█ █▄█ █▀█ █▀█ █░▀░█   █▄▀ █▀█ ░█░ ░█░ █▀█
EOF
# Get current UTC time, rounded down to last full hour
UTC_DATE=$(date -u "+%Y-%m-%d")
UTC_HOUR=$(date -u "+%H")
FORMATTED_HOUR=$(printf "%02d" "$UTC_HOUR")
TIMESTAMP="${UTC_DATE}-${FORMATTED_HOUR}-00"

# Dynamic consensus snapshot URL
CONSENSUS_URL="https://collector.torproject.org/recent/relay-descriptors/consensuses/${TIMESTAMP}-consensus"

# Temporary file
TMP_FILE=$(mktemp)

echo -e "\n📥 Downloading Tor consensus snapshot from: $CONSENSUS_URL"
curl -s "$CONSENSUS_URL" -o "$TMP_FILE"

# Validate the consensus file
if ! grep -q "^network-status-version" "$TMP_FILE"; then
    echo "❌ Error: Not a valid consensus file or snapshot not available for this hour."
    rm "$TMP_FILE"
    exit 1
fi

# Start interactive session
while true; do
    echo -e "\n--- Tor Consensus Interactive Menu ---"
    select opt in "Summary of Relay Types" "Search Relays by Country" "List Exit Relays" "Quit"; do
        case $REPLY in
            1)
                echo "📊 Relay Summary:"
                echo "Total relays: $(grep -c '^r ' "$TMP_FILE")"
                echo "Guard relays: $(awk '/^r / {r=$2} /^s / {if (/Guard/) print r}' "$TMP_FILE" | wc -l)"
                echo "Exit relays : $(awk '/^r / {r=$2} /^s / {if (/Exit/) print r}' "$TMP_FILE" | wc -l)"
                echo "Authorities : $(awk '/^r / {r=$2} /^s / {if (/Authority/) print r}' "$TMP_FILE" | wc -l)"
                break
                ;;
            2)
                read -p "Enter 2-letter country code (e.g., US, DE, NL): " cc
                echo "🌍 Relays in $cc:"
                grep "^r " "$TMP_FILE" | grep -i " $cc" | awk '{print "Relay:", $2, "IP:", $6}' | head -n 20
                break
                ;;
            3)
                echo "🚪 First 20 Exit relays:"
                awk '
                /^r / { r=$2; ip=$6 }
                /^s / { if (/Exit/) print "Relay:", r, "IP:", ip }
                ' "$TMP_FILE" | head -n 20
                break
                ;;
            4)
                echo "👋 Exiting. Cleaning up..."
                rm "$TMP_FILE"
                exit 0
                ;;
            *)
                echo "❗ Invalid option. Try again."
                ;;
        esac
    done
done
