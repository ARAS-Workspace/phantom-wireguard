"""
██████╗ ██╗  ██╗ █████╗ ███╗   ██╗████████╗ ██████╗ ███╗   ███╗
██╔══██╗██║  ██║██╔══██╗████╗  ██║╚══██╔══╝██╔═══██╗████╗ ████║
██████╔╝███████║███████║██╔██╗ ██║   ██║   ██║   ██║██╔████╔██║
██╔═══╝ ██╔══██║██╔══██║██║╚██╗██║   ██║   ██║   ██║██║╚██╔╝██║
██║     ██║  ██║██║  ██║██║ ╚████║   ██║   ╚██████╔╝██║ ╚═╝ ██║
╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝ ╚═╝     ╚═╝

ConfigGenerationService Component Integration Tests

Copyright (c) 2025 Rıza Emre ARAS <r.emrearas@proton.me>
Licensed under AGPL-3.0 - see LICENSE file for details
Third-party licenses - see THIRD_PARTY_LICENSES file for details
WireGuard® is a registered trademark of Jason A. Donenfeld.
"""

import pytest

from phantom.modules.core.lib.config_generation_service import ConfigGenerationService


class TestConfigGenerationService:

    @pytest.fixture
    def environment(self):
        """Environment fixture"""
        return {
            'config': {
                "dns": {
                    "primary": "1.1.1.1",
                    "secondary": "1.0.0.1"
                },
                "server": {
                    "public_key": "serverPublicKey12345678901234567890123456789=",
                    "ip": "192.168.100.50"
                },
                "wireguard": {
                    "port": 51820,
                    "network": "10.8.0.0/24"
                }
            },
            'sample_keys': {
                "private": "clientPrivateKey123456789012345678901234567=",
                "public": "clientPublicKey1234567890123456789012345678=",
                "preshared": "presharedKey12345678901234567890123456789=="
            }
        }

    @pytest.mark.integration
    def test_full_configuration(self, environment):
        """Test generation of complete WireGuard client configuration with all parameters."""
        # Get test configuration and sample keys from the test environment
        config = environment['config']
        sample_keys = environment['sample_keys']

        # Prepare client data with all required fields for configuration generation
        client_data = {
            "private_key": sample_keys["private"],
            "ip": "10.8.0.2",
            "preshared_key": sample_keys["preshared"]
        }

        # Initialize service with test configuration and generate client config
        service = ConfigGenerationService(config)
        result = service.generate_client_config(client_data)

        # Verify that both required configuration sections are present
        assert '[Interface]' in result
        assert '[Peer]' in result

        # Verify Interface section contains all required client parameters
        assert f'PrivateKey = {sample_keys["private"]}' in result
        assert 'Address = 10.8.0.2/24' in result  # Client IP with network mask
        assert 'DNS = 1.1.1.1, 1.0.0.1' in result  # Configured DNS servers
        assert 'MTU = 1420' in result  # Default MTU value

        # Verify Peer section contains all server connection parameters
        assert f'PublicKey = {config["server"]["public_key"]}' in result  # Server public key
        assert f'PresharedKey = {sample_keys["preshared"]}' in result  # Preshared key for extra security
        assert 'Endpoint = 192.168.100.50:51820' in result  # Server endpoint
        assert 'AllowedIPs = 0.0.0.0/0, 10.8.0.0/24' in result  # Route all traffic through VPN
        assert 'PersistentKeepalive = 25' in result  # Keep connection alive

    @pytest.mark.integration
    def test_dns_fallback(self):
        """Test DNS fallback to default values when DNS is not configured."""
        # Create configuration without DNS settings to test fallback behavior
        config_no_dns = {
            "server": {
                "public_key": "serverKey1234567890123456789012345678901234=",
                "ip": "192.168.1.1"
            },
            "wireguard": {
                "port": 51820
            }
        }

        # Prepare client data for configuration generation
        client_data = {
            "private_key": "clientKey12345678901234567890123456789012345=",
            "ip": "10.8.0.2",
            "preshared_key": "presharedKey123456789012345678901234567890="
        }

        # Generate configuration and verify it uses fallback DNS servers
        service = ConfigGenerationService(config_no_dns)
        result = service.generate_client_config(client_data)

        # Verify default DNS servers (8.8.8.8, 1.1.1.1) are used when not configured
        assert "DNS = 8.8.8.8, 1.1.1.1" in result

    @pytest.mark.integration
    def test_server_endpoint_fallback(self):
        """Test server endpoint fallback logic for different configuration scenarios."""
        # Prepare common client data to be used across all test scenarios
        client_data = {
            "private_key": "testPrivateKey12345678901234567890123456789=",
            "ip": "10.8.0.2",
            "preshared_key": "testPresharedKey123456789012345678901234567="
        }

        # Test case 1: Verify wireguard.server_ip takes precedence over server.ip
        config_with_server_ip = {
            "server": {
                "public_key": "serverKey123=",
                "ip": "192.168.1.1"  # This will be ignored
            },
            "wireguard": {
                "server_ip": "203.0.113.1",  # This takes precedence
                "port": 51820
            }
        }

        service = ConfigGenerationService(config_with_server_ip)
        result = service.generate_client_config(client_data)
        assert "Endpoint = 203.0.113.1:51820" in result  # Uses wireguard.server_ip

        # Test case 2: Verify fallback to server.ip when wireguard.server_ip is not set
        config_with_ip = {
            "server": {
                "public_key": "serverKey123=",
                "ip": "192.168.1.1"  # This will be used as fallback
            },
            "wireguard": {
                "port": 51820
            }
        }

        service = ConfigGenerationService(config_with_ip)
        result = service.generate_client_config(client_data)
        assert "Endpoint = 192.168.1.1:51820" in result  # Uses server.ip as fallback

        # Test case 3: Verify placeholder is used when no server IP is configured
        config_no_server = {
            "server": {
                "public_key": "serverKey123="
                # No IP configured
            },
            "wireguard": {
                "port": 51820
            }
        }

        service = ConfigGenerationService(config_no_server)
        result = service.generate_client_config(client_data)
        assert "Endpoint = YOUR_SERVER_IP:51820" in result  # Placeholder for manual configuration

    @pytest.mark.integration
    def test_port_and_network_defaults(self):
        """Test default values for port and network when not explicitly configured."""
        # Prepare client data for both test scenarios
        client_data = {
            "private_key": "testKey12345678901234567890123456789012345==",
            "ip": "10.8.0.2",
            "preshared_key": "testPreshared12345678901234567890123456789="
        }

        # Test case 1: Verify default port (51820) when port is not configured
        config_no_port = {
            "server": {
                "public_key": "serverKey=",
                "ip": "192.168.1.1"
            },
            "wireguard": {
                "network": "10.8.0.0/24"
            }
        }

        service = ConfigGenerationService(config_no_port)
        result = service.generate_client_config(client_data)
        assert ":51820" in result  # Default WireGuard port should be used

        # Test case 2: Verify default network (10.8.0.0/24) when network is not configured
        config_no_network = {
            "server": {
                "public_key": "serverKey=",
                "ip": "192.168.1.1"
            },
            "wireguard": {
                "port": 51820
            }
        }

        service = ConfigGenerationService(config_no_network)
        result = service.generate_client_config(client_data)
        assert "AllowedIPs = 0.0.0.0/0, 10.8.0.0/24" in result  # Default network should be included

    @pytest.mark.integration
    def test_client_data_handling(self):
        """Test handling of client data with and without optional preshared key."""
        # Setup base configuration for testing client data variations
        config = {
            "server": {
                "public_key": "serverKey12345678901234567890123456789012345=",
                "ip": "192.168.1.1"
            },
            "wireguard": {
                "port": 51820,
                "network": "10.8.0.0/24"
            }
        }

        service = ConfigGenerationService(config)

        # Test case 1: Client with preshared key for enhanced security
        client_with_preshared = {
            "private_key": "clientPrivateKey1234567890123456789012345678=",
            "ip": "10.8.0.5",
            "preshared_key": "presharedKey123456789012345678901234567890=="
        }

        result = service.generate_client_config(client_with_preshared)
        # Verify all client data is correctly included in configuration
        assert "PrivateKey = clientPrivateKey1234567890123456789012345678=" in result
        assert "Address = 10.8.0.5/24" in result
        assert "PresharedKey = presharedKey123456789012345678901234567890==" in result

        # Test case 2: Client without preshared key (optional field)
        client_without_preshared = {
            "private_key": "clientPrivateKey2234567890123456789012345678=",
            "ip": "10.8.0.6"
        }

        result = service.generate_client_config(client_without_preshared)
        # Verify configuration handles missing optional preshared key gracefully
        assert "PrivateKey = clientPrivateKey2234567890123456789012345678=" in result
        assert "Address = 10.8.0.6/24" in result
        assert "PresharedKey = " in result  # Empty value when not provided

    @pytest.mark.integration
    def test_configuration_format(self):
        """Test the correct formatting and structure of generated WireGuard configuration."""
        # Setup configuration with domain name endpoint to test hostname support
        config = {
            "dns": {
                "primary": "8.8.8.8",
                "secondary": "8.8.4.4"
            },
            "server": {
                "public_key": "serverPublicKey1234567890123456789012345678=",
                "ip": "vpn.example.com"  # Using domain name instead of IP
            },
            "wireguard": {
                "port": 51820,
                "network": "10.8.0.0/24"
            }
        }

        # Prepare client data for configuration generation
        client_data = {
            "private_key": "clientPrivateKey123456789012345678901234567=",
            "ip": "10.8.0.10",
            "preshared_key": "presharedKey123456789012345678901234567890="
        }

        # Generate configuration and parse into lines for structural verification
        service = ConfigGenerationService(config)
        result = service.generate_client_config(client_data)
        lines = result.split('\n')

        # Verify configuration starts with Interface section
        assert lines[0] == '[Interface]'
        peer_index = lines.index('[Peer]')
        assert peer_index > 0

        # Verify proper spacing between sections
        assert lines[peer_index - 1] == ''

        # Verify proper key-value format with consistent spacing
        for line in lines:
            if line and not line.startswith('['):
                assert ' = ' in line
                key, value = line.split(' = ', 1)
                assert key.strip() == key  # No extra spaces

        # Verify Interface section parameter order
        interface_lines = [l for l in lines[1:peer_index - 1] if l]
        assert interface_lines[0].startswith('PrivateKey')
        assert interface_lines[1].startswith('Address')
        assert interface_lines[2].startswith('DNS')
        assert interface_lines[3].startswith('MTU')

        # Verify Peer section parameter order
        peer_lines = [l for l in lines[peer_index + 1:] if l]
        assert peer_lines[0].startswith('PublicKey')
        assert peer_lines[1].startswith('PresharedKey')
        assert peer_lines[2].startswith('Endpoint')
        assert peer_lines[3].startswith('AllowedIPs')
        assert peer_lines[4].startswith('PersistentKeepalive')

    @pytest.mark.integration
    def test_edge_cases(self):
        """Test edge cases including empty config and missing required fields."""
        # Test case 1: Service with empty configuration to test all defaults
        service = ConfigGenerationService({})

        # Prepare client data for testing with empty service configuration
        client_data = {
            "private_key": "clientKey12345678901234567890123456789012345=",
            "ip": "10.8.0.2",
            "preshared_key": "pre1234567890123456789012345678901234567890="
        }

        # Generate configuration with empty service config to verify all defaults work
        result = service.generate_client_config(client_data)

        # Verify configuration is still generated with all default values
        assert '[Interface]' in result
        assert '[Peer]' in result
        assert 'DNS = 8.8.8.8, 1.1.1.1' in result  # Default DNS
        assert ':51820' in result  # Default port
        assert 'YOUR_SERVER_IP' in result  # Placeholder when no server configured

        # Test case 2: Client data missing required IP field
        client_missing_ip = {
            "private_key": "clientKey=",
            "preshared_key": "pre="
        }

        # Verify proper error handling for missing IP field
        with pytest.raises(KeyError):
            service.generate_client_config(client_missing_ip)

        # Test case 3: Client data missing required private_key field
        client_missing_private_key = {
            "ip": "10.8.0.2",
            "preshared_key": "pre="
        }

        # Verify proper error handling for missing private_key field
        with pytest.raises(KeyError):
            service.generate_client_config(client_missing_private_key)
