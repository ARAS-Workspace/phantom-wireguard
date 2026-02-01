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

**Kendi Sunucun. Kendi Ağın. Kendi Gizliliğin.**

Phantom-WireGuard, kendi sunucunuzda WireGuard VPN altyapısı kurmanızı ve yönetmenizi sağlayan
modüler bir araçtır. Temel VPN yönetiminin ötesinde; sansüre dayanıklı bağlantılar, çok katmanlı
şifreleme ve gelişmiş gizlilik senaryoları sunar.


:fontawesome-solid-globe: **[https://www.phantom.tc](https://www.phantom.tc)**

:fontawesome-brands-github: **[Github](https://github.com/ARAS-Workspace/phantom-wireguard)**


## Hızlı Başlangıç

### Gereksinimler

**Sunucu:**

- İnternet erişimi ve genel (public) IPv4 adresine sahip, desteklenen işletim sistemlerinden birine sahip sunucu
- Root erişimi

**İşletim Sistemi:**

- Debian 12, 13
- Ubuntu 22.04, 24.04

> **Kaynak Kullanımı:** WireGuard kernel modülü olarak çalıştığı için minimal sistem kaynağı kullanır.
> Detaylı performans bilgisi için [WireGuard Performance](https://www.wireguard.com/performance/) sayfasına bakınız.

### Kurulum

```bash
curl -sSL https://install.phantom.tc | bash
```

<div class="asciinema-player-container">
    <div class="asciinema-player-header">
        <h3>Phantom WireGuard</h3>
        <span class="asciinema-player-info">Terminal Kaydı</span>
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

### İstemci Oluşturma

Kurulum tamamlandıktan sonra interaktif CLI ile istemci oluşturabilirsiniz:
```bash
phantom-wireguard
```

**CLI Navigasyonu:**

1. `1` → Core Management
2. `1` → Client Operations  
3. `1` → Add new client
4. İstemci adını girin (örn: `test-client`)
5. `3` → Export client config
6. Konfigürasyonu kopyalayın veya dosyaya kaydedin

<div class="asciinema-player-container">
    <div class="asciinema-player-header">
        <h3>Phantom WireGuard</h3>
        <span class="asciinema-player-info">Terminal Kaydı</span>
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
  <strong>Konfigürasyon Güvenliği:</strong> İstemci konfigürasyonu özel anahtarlar içerir. 
  Dosyayı istemci cihaza aktarırken güvenli kanallar (SCP, SFTP, uçtan uca şifreli mesajlaşma) kullanın. 
  Konfigürasyonu asla e-posta veya şifresiz kanallarla paylaşmayın.
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

### İstemci Bağlantısı

Konfigürasyon dosyasını istemci cihaza aktardıktan sonra:

```bash
# Konfigürasyonu WireGuard dizinine taşıyın
sudo mv client.conf /etc/wireguard/wg0.conf

# VPN bağlantısını başlatın
sudo wg-quick up wg0

# Bağlantı durumunu kontrol edin
sudo wg show

# Genel IP adresinizi doğrulayın
curl -4 ifconfig.io
```

<div class="asciinema-player-container">
    <div class="asciinema-player-header">
        <h3>Phantom WireGuard</h3>
        <span class="asciinema-player-info">Terminal Kaydı</span>
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

## Erişim Yöntemleri

| Yöntem             | Komut                         | Açıklama                            |
|--------------------|-------------------------------|-------------------------------------|
| **İnteraktif CLI** | `phantom-wireguard`           | Rich TUI tabanlı kullanıcı arayüzü  |
| **API**            | `phantom-api <modül> <eylem>` | Programatik erişim, JSON çıktı      |
| **Ghost Export**   | `phantom-casper <istemci>`    | Ghost Mode istemci yapılandırması   |

---

## Lisans

Copyright (c) 2025 Rıza Emre ARAS <r.emrearas@proton.me>

Bu yazılım AGPL-3.0 lisansı altında lisanslanmıştır. Detaylar için [LICENSE](https://raw.githubusercontent.com/ARAS-Workspace/phantom-wireguard/refs/heads/main/LICENSE) dosyasına bakınız.

Üçüncü taraf lisansları için [THIRD_PARTY_LICENSES](https://raw.githubusercontent.com/ARAS-Workspace/phantom-wireguard/refs/heads/main/THIRD_PARTY_LICENSES) dosyasına bakınız.

WireGuard® Jason A. Donenfeld'in tescilli ticari markasıdır.

---

## Destek

Phantom-WireGuard açık kaynak bir projedir. Projeyi desteklemek isterseniz:

**Monero (XMR):**
```
84KzoZga5r7avaAqrWD4JhXaM6t69v3qe2gyCGNNxAaaJgFizt1NzAQXtYoBk1xJPXEHNi6GKV1SeDZWUX7rxzaAQeYyZwQ
```

**Bitcoin (BTC):**
```
bc1qnjjrsfdatnc2qtjpkzwpgxpmnj3v4tdduykz57
```
