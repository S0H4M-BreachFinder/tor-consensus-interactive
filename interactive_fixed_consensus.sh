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
#!/bin/bash

# Developed by Soham Datta

# URL of consensus directory
BASE_URL="https://collector.torproject.org/recent/relay-descriptors/consensuses/"

# Temporary file to store index and consensus
TMP_INDEX=$(mktemp)
TMP_CONSENSUS=$(mktemp)

# Fetch the index HTML
echo "📥 Fetching consensus index page..."
curl -s "$BASE_URL" -o "$TMP_INDEX"

# Extract consensus filenames from HTML
consensus_files=($(grep -oP '\d{4}-\d{2}-\d{2}-\d{2}-00-00-consensus' "$TMP_INDEX"))

# Check if files found
if [ ${#consensus_files[@]} -eq 0 ]; then
    echo "❌ No consensus files found."
    rm "$TMP_INDEX" "$TMP_CONSENSUS"
    exit 1
fi

# Pick a random file
RANDOM_FILE=${consensus_files[$RANDOM % ${#consensus_files[@]}]}
DOWNLOAD_URL="${BASE_URL}${RANDOM_FILE}"

echo "🎯 Selected random consensus file: $RANDOM_FILE"
echo "🌐 Downloading from: $DOWNLOAD_URL"
curl -s "$DOWNLOAD_URL" -o "$TMP_CONSENSUS"

# Validate the consensus file
if ! grep -q "^network-status-version" "$TMP_CONSENSUS"; then
    echo "❌ Error: Not a valid consensus file."
    rm "$TMP_INDEX" "$TMP_CONSENSUS"
    exit 1
fi

# Start interactive session
while true; do
    echo -e "\n--- Tor Consensus Interactive Menu ---"
    select opt in "Summary of Relay Types" "Search Relays by Country" "List Exit Relays" "Quit"; do
        case $REPLY in
            1)
                echo "📊 Relay Summary:"
                echo "Total relays: $(grep -c '^r ' "$TMP_CONSENSUS")"
                echo "Guard relays: $(awk '/^r / {r=$2} /^s / {if (/Guard/) print r}' "$TMP_CONSENSUS" | wc -l)"
                echo "Exit relays : $(awk '/^r / {r=$2} /^s / {if (/Exit/) print r}' "$TMP_CONSENSUS" | wc -l)"
                echo "Authorities : $(awk '/^r / {r=$2} /^s / {if (/Authority/) print r}' "$TMP_CONSENSUS" | wc -l)"
                break
                ;;
            2)
                read -p "Enter 2-letter country code (e.g., US, DE, NL): " cc
                echo "🌍 Relays in $cc:"
                grep "^r " "$TMP_CONSENSUS" | grep -i " $cc" | awk '{print "Relay:", $2, "IP:", $6}' | head -n 20
                break
                ;;
            3)
                echo "🚪 First 20 Exit relays:"
                awk '
                /^r / { r=$2; ip=$6 }
                /^s / { if (/Exit/) print "Relay:", r, "IP:", ip }
                ' "$TMP_CONSENSUS" | head -n 20
                break
                ;;
            4)
                echo "👋 Exiting. Cleaning up..."
                rm "$TMP_INDEX" "$TMP_CONSENSUS"
                exit 0
                ;;
            *)
                echo "❗ Invalid option. Try again."
                ;;
        esac
    done
done
