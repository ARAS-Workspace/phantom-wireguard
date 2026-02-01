---
extra_javascript:
  - assets/javascripts/asciinema-player.js
  - assets/javascripts/phantom-ascii.js
  - assets/javascripts/animated-ascii-art.js
extra_css:
  - assets/stylesheets/ascii-styles.css
  - assets/stylesheets/animated-ascii-art.css

---
# Phantom-WireGuard

<div class="ascii-demo-container">
  <pre id="phantom-ascii-pulse" class="ascii-art" data-effect="pulse"></pre>
</div>

**Your Server. Your Network. Your Privacy.**

Phantom-WireGuard is a modular tool for setting up and managing WireGuard VPN
infrastructure on your own server. Beyond basic VPN management, it provides
censorship-resistant connections, multi-layer encryption, and advanced privacy scenarios.


:fontawesome-solid-globe: **[https://www.phantom.tc](https://www.phantom.tc)**

:fontawesome-brands-github: **[Github](https://github.com/ARAS-Workspace/phantom-wireguard)**


## Quick Start

### Requirements

**Server:**

- A server with internet access, a public IPv4 address, and a supported operating system
- Root access

**Operating System:**

- Debian 12, 13
- Ubuntu 22.04, 24.04

> **Resource Usage:** WireGuard runs as a kernel module, consuming minimal system resources.
> For detailed performance information, see [WireGuard Performance](https://www.wireguard.com/performance/).

### Installation

```bash
curl -sSL https://install.phantom.tc | bash
```

<div class="asciinema-player-container">
    <div class="asciinema-player-header">
        <h3>Phantom WireGuard</h3>
        <span class="asciinema-player-info">Terminal Recording</span>
    </div>
    <div class="asciinema-player-wrapper">
        <div class="asciinema-player"
             data-cast-file="recordings/index/installation"
             data-cols="120"
             data-rows="48"
             data-autoplay="false"
             data-loop="false"
             data-speed="1.5"
             data-theme="solarized-dark"
             data-font-size="small">
        </div>
    </div>
</div>

### Creating a Client

After the installation is complete, you can create a client using the interactive CLI:
```bash
phantom-wireguard
```

**CLI Navigation:**

1. `1` → Core Management
2. `1` → Client Operations
3. `1` → Add new client
4. Enter the client name (e.g., `test-client`)
5. `3` → Export client config
6. Copy the configuration or save it to a file

<div class="asciinema-player-container">
    <div class="asciinema-player-header">
        <h3>Phantom WireGuard</h3>
        <span class="asciinema-player-info">Terminal Recording</span>
    </div>
    <div class="asciinema-player-wrapper">
        <div class="asciinema-player"
             data-cast-file="recordings/index/create-and-export-client"
             data-cols="120"
             data-rows="48"
             data-autoplay="false"
             data-loop="false"
             data-speed="1.5"
             data-theme="solarized-dark"
             data-font-size="small">
        </div>
    </div>
</div>

<div class="phantom-alert warning">
  <i class="fas fa-exclamation-triangle"></i>
  <strong>Configuration Security:</strong> The client configuration contains private keys.
  Use secure channels (SCP, SFTP, end-to-end encrypted messaging) when transferring the file to the client device.
  Never share the configuration via email or unencrypted channels.
</div>

<div class="asciinema-player"
     data-cast-file="recordings/index/transfer-configuration-to-client"
     data-cols="120"
     data-rows="12"
     data-autoplay="false"
     data-loop="false"
     data-speed="1.5"
     data-theme="solarized-dark"
     data-font-size="small">
</div>

### Client Connection

After transferring the configuration file to the client device:

```bash
# Move the configuration to the WireGuard directory
sudo mv client.conf /etc/wireguard/wg0.conf

# Start the VPN connection
sudo wg-quick up wg0

# Check the connection status
sudo wg show

# Verify your public IP address
curl -4 ifconfig.io
```

<div class="asciinema-player-container">
    <div class="asciinema-player-header">
        <h3>Phantom WireGuard</h3>
        <span class="asciinema-player-info">Terminal Recording</span>
    </div>
    <div class="asciinema-player-wrapper">
        <div class="asciinema-player"
             data-cast-file="recordings/index/connection"
             data-cols="120"
             data-rows="48"
             data-autoplay="false"
             data-loop="false"
             data-speed="1.5"
             data-theme="solarized-dark"
             data-font-size="small">
        </div>
    </div>
</div>

---

## Access Methods

| Method              | Command                         | Description                      |
|---------------------|---------------------------------|----------------------------------|
| **Interactive CLI** | `phantom-wireguard`             | Rich TUI-based user interface    |
| **API**             | `phantom-api <module> <action>` | Programmatic access, JSON output |
| **Ghost Export**    | `phantom-casper <client>`       | Ghost Mode client configuration  |

---

## License

Copyright (c) 2025 Riza Emre ARAS <r.emrearas@proton.me>

This software is licensed under the AGPL-3.0 license. See [LICENSE](https://raw.githubusercontent.com/ARAS-Workspace/phantom-wireguard/refs/heads/main/LICENSE) for details.

For third-party licenses, see [THIRD_PARTY_LICENSES](https://raw.githubusercontent.com/ARAS-Workspace/phantom-wireguard/refs/heads/main/THIRD_PARTY_LICENSES).

WireGuard® is a registered trademark of Jason A. Donenfeld.

---

## Support

Phantom-WireGuard is an open-source project. If you'd like to support the project:

**Monero (XMR):**
```
84KzoZga5r7avaAqrWD4JhXaM6t69v3qe2gyCGNNxAaaJgFizt1NzAQXtYoBk1xJPXEHNi6GKV1SeDZWUX7rxzaAQeYyZwQ
```

**Bitcoin (BTC):**
```
bc1qnjjrsfdatnc2qtjpkzwpgxpmnj3v4tdduykz57
```