
---

### 📄 `README.md`

```markdown
# 🧅 Tor Consensus Interactive Inspector

This project is a Bash script that provides an **interactive interface** to explore the Tor network consensus. It downloads a specified consensus file from [Tor Project's CollecTor](https://collector.torproject.org) and lets you inspect relay information such as:

- Relay type summaries (Guard, Exit, Authority)
- Exit relays
- Relays by country code

## 🔗 Consensus Source

This script uses a **fixed snapshot** of the consensus document from:

```

[https://collector.torproject.org/recent/relay-descriptors/consensuses/2025-05-03-16-00-00-consensus](https://collector.torproject.org/recent/relay-descriptors/consensuses/2025-05-03-16-00-00-consensus)

````

This file contains detailed relay status entries as agreed upon by Tor directory authorities.

## 🧰 Requirements

- `bash`
- `curl`
- `awk`
- `grep`

All of these are available by default on most Linux/macOS systems.

## ▶️ Usage

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/tor-consensus-interactive.git
   cd tor-consensus-interactive
````

2. Make the script executable:

   ```bash
   chmod +x interactive_fixed_consensus.sh
   ```

3. Run the script:

   ```bash
   ./interactive_fixed_consensus.sh
   ```

4. Choose an option from the menu:

   ```
   --- Tor Consensus Interactive Menu ---
   1) Summary of Relay Types
   2) Search Relays by Country
   3) List Exit Relays
   4) Quit
   ```

## 📦 Features

* 🧮 **Relay statistics**: View total number of relays, exit nodes, guards, and authorities.
* 🌍 **Country search**: Find relays registered under a specific country code.
* 🚪 **Exit relay list**: View the first 20 exit-capable relays.

## 📁 File Structure

```
interactive_fixed_consensus.sh  # Main script
README.md                       # This file
```

## 🚀 Future Improvements

* Add bandwidth display (`w` lines)
* Integrate with `geoiplookup` for richer IP metadata
* Allow selection of recent consensus files dynamically
* Export filtered data to CSV or JSON

## 🛡 Disclaimer

This tool is for educational and research purposes only. It does not interact with or modify the Tor network. All data is retrieved from public and official Tor Project archives.

---

