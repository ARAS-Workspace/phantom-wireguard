# Installation - Kayıt Senaryosu

## Ortam

| Sunucu | Rol                 | Kullanıcı |
|--------|---------------------|-----------|
| master | Kontrol sunucusu    | root      |
| server | Phantom-WG sunucusu | root      |
| client | Test istemcisi      | client    |

---

## Senaryo Akışı

### 1. SERVER - Phantom-WG kurulumu

```bash
ssh server
```

```bash
curl -sSL https://install.phantom.tc | bash
```

---

### 2. SERVER - Client oluştur ve export et

```bash
phantom-api core add_client client_name="test-client"
```

```bash
phantom-api core export_client client_name="test-client" | jq -r '.data.config' > test-client.conf
```

```bash
exit
```

---

### 3. MASTER - Config dosyasını transfer et

```bash
scp server:test-client.conf .
```

```bash
scp test-client.conf client:
```

---

### 4. CLIENT - WireGuard bağlantısı kur

```bash
ssh client
```

```bash
sudo wg-quick up ./test-client.conf
```

```bash
clear
```

```bash
sudo wg show
```

```bash
curl --ipv4 ifconfig.io
```

---

## Özet Akış

```
SERVER: phantom-install → add_client → export → exit
MASTER: scp server→master → scp master→client
CLIENT: wg-quick up → clear → wg show → curl ifconfig.io
```
