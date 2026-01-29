"""
██████╗ ██╗  ██╗ █████╗ ███╗   ██╗████████╗ ██████╗ ███╗   ███╗
██╔══██╗██║  ██║██╔══██╗████╗  ██║╚══██╔══╝██╔═══██╗████╗ ████║
██████╔╝███████║███████║██╔██╗ ██║   ██║   ██║   ██║██╔████╔██║
██╔═══╝ ██╔══██║██╔══██║██║╚██╗██║   ██║   ██║   ██║██║╚██╔╝██║
██║     ██║  ██║██║  ██║██║ ╚████║   ██║   ╚██████╔╝██║ ╚═╝ ██║
╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝

TR: ConfigGenerationService - Dinamik WireGuard yapılandırma dosyası üretimi
    ========================================================================
    
    Bu servis, WireGuard istemci yapılandırma dosyalarını dinamik olarak üretir.
    
    Ana Sorumluluklar:
        - İstemci verilerini TinyDB'den alma
        - Global ayarları phantom.json'dan okuma
        - WireGuard yapılandırma formatında birleştirme
        - DNS, MTU, endpoint ayarlarını ekleme
        - Güvenlik anahtarlarını (preshared) dahil etme
        
    Veri Kaynakları:
        - TinyDB: İstemci özel anahtarı, IP adresi, preshared key
        - Global Config: DNS sunucuları, sunucu bilgileri, port
        - Sabit Değerler: MTU (1420), keepalive (25)
        
    Özellikler:
        - Dosya sistemi kullanmaz, sadece bellek işlemleri
        - Template tabanlı yapılandırma üretimi
        - Fallback değerler ile hata toleransı
        - Standard WireGuard formatı uyumluluğu

EN: ConfigGenerationService - Dynamic WireGuard configuration file generation
    ========================================================================
    
    This service dynamically generates WireGuard client configuration files.

    Main Responsibilities:
        - Retrieve client data from TinyDB
        - Read global settings from phantom.json
        - Combine in WireGuard configuration format
        - Add DNS, MTU, endpoint settings
        - Include security keys (preshared)
        
    Data Sources:
        - TinyDB: Client private key, IP address, preshared key
        - Global Config: DNS servers, server info, port
        - Static Values: MTU (1420), keepalive (25)
        
    Features:
        - No filesystem usage, memory-only operations
        - Template-based configuration generation
        - Error tolerance with fallback values
        - Standard WireGuard format compatibility

Copyright (c) 2025 Rıza Emre ARAS <r.emrearas@proton.me>
Licensed under AGPL-3.0 - see LICENSE file for details
Third-party licenses - see THIRD_PARTY_LICENSES file for details
WireGuard® is a registered trademark of Jason A. Donenfeld.
"""

from typing import Dict, Any
from textwrap import dedent

from .default_constants import (
    DEFAULT_WG_NETWORK,
    DEFAULT_MTU,
    DEFAULT_KEEPALIVE,
    DEFAULT_DNS_PRIMARY,
    DEFAULT_DNS_SECONDARY,
    DEFAULT_WG_PORT,
    DEFAULT_CLIENT_CIDR
)


class ConfigGenerationService:
    """Generates WireGuard client configuration files dynamically.

    Combines client-specific data from database with global settings
    to produce standard WireGuard configuration format. All operations
    are performed in memory without filesystem access.

    Data Sources:
        - Client database: private key, IP address, preshared key
        - Global config: DNS servers, server endpoint, network settings
        - Static defaults: MTU, keepalive, port values
    """

    def __init__(self, config: Dict[str, Any]):
        self.config = config

    def generate_client_config(self, client_data: Dict[str, Any]) -> str:
        """Generate WireGuard configuration content for a client.

        Args:
            client_data: Dictionary containing client's private_key, ip,
                         and optionally preshared_key

        Returns:
            String containing complete WireGuard configuration file content
        """
        dns_config = self.config.get("dns", {})
        dns_primary = dns_config.get("primary", DEFAULT_DNS_PRIMARY)
        dns_secondary = dns_config.get("secondary", DEFAULT_DNS_SECONDARY)

        wg_config = self.config.get("wireguard", {})
        server_config = self.config.get("server", {})

        server_public_key = server_config.get("public_key", "")

        # Try multiple config locations for endpoint
        server_ip = (wg_config.get("server_ip") or
                     server_config.get("ip") or
                     wg_config.get("endpoint") or
                     "YOUR_SERVER_IP")

        server_port = wg_config.get("port", DEFAULT_WG_PORT)
        network = wg_config.get("network", DEFAULT_WG_NETWORK)

        # Build WireGuard configuration
        config = dedent(f"""
            [Interface]
            PrivateKey = {client_data['private_key']}
            Address = {client_data['ip']}{DEFAULT_CLIENT_CIDR}
            DNS = {dns_primary}, {dns_secondary}
            MTU = {DEFAULT_MTU}

            [Peer]
            PublicKey = {server_public_key}
            PresharedKey = {client_data.get('preshared_key', '')}
            Endpoint = {server_ip}:{server_port}
            AllowedIPs = 0.0.0.0/0, {network}
            PersistentKeepalive = {DEFAULT_KEEPALIVE}
            """).strip()

        return config
