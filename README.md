# Linux Scripts

Scripts de post-instalación y utilidades para Linux (Debian).

## Contenido

### debian13-mate-postinstall.sh
Script de post-instalación desatendida para **Debian 13 (Trixie) + MATE**.

### debian-sid-mate-postinstall.sh
Script de post-instalación desatendida para **Debian Sid (Unstable) + MATE**.

## ¿Qué instalan ambos scripts?

### Sistema Base
- Firmware completo (AMD, Intel, Realtek, Broadcom, Qualcomm, etc.)
- Utilidades del sistema (htop, btop, samba, gdebi, net-tools)
- Tema Arc-Dark + iconos Papirus-Dark
- Complementos de Caja (13 extensiones)

### Multimedia
- **PipeWire** + WirePlumber (reemplaza PulseAudio)
- Plugins: ALSA, Bluetooth, JACK, Libcamera, V4L2, XRDP
- Kodi 21 + addons (PVR, InputStream, codecs, VFS)
- RetroArch, OpenRCT2

### Drivers
- **AMD**: Mesa Vulkan (64-bit + 32-bit), libGL, radeontop
- **WineHQ Stable** (repositorio oficial)
- **Brave Browser** (instalación automática)

### Programas de Diseño y Multimedia
- Inkscape, Krita, GIMP
- Scribus, Darktable
- OpenShot, Audacity, DVDStyler
- SimpleScreenRecorder, GuvcView
- aMule, Filezilla, qBittorrent
- Blender

### Seguridad / Auditoría
- Wifite, Bully, Hashcat
- hcxdumptool, hcxtools
- Wireshark, Macchanger

### Configuración del Escritorio
- Autologin en LightDM
- Panel MATE personalizado (reloj, notification area, window list, system monitor, netspeed)
- Fondo de pantalla MATE
- Aplicación automática de tema al primer inicio

### Repositorios Adicionales
- **deb-multimedia** (codecs y multimedia)
- **MX Linux** (solo en script de Debian 13 estable)
- **WineHQ** (repositorio oficial)

## Uso

### Descarga directa

```bash
# Debian 13 estable
curl -O https://kodipc.serv00.net/apks/debian13-mate-postinstall.sh
chmod +x debian13-mate-postinstall.sh
sudo ./debian13-mate-postinstall.sh
```

```bash
# Debian Sid
curl -O https://kodipc.serv00.net/apks/debian-sid-mate-postinstall.sh
chmod +x debian-sid-mate-postinstall.sh
sudo ./debian-sid-mate-postinstall.sh
```

O usando `wget`:

```bash
# Debian 13 estable
wget https://kodipc.serv00.net/apks/debian13-mate-postinstall.sh
chmod +x debian13-mate-postinstall.sh
sudo ./debian13-mate-postinstall.sh
```

```bash
# Debian Sid
wget https://kodipc.serv00.net/apks/debian-sid-mate-postinstall.sh
chmod +x debian-sid-mate-postinstall.sh
sudo ./debian-sid-mate-postinstall.sh
```

### Ejecución directa (sin descargar)

```bash
# Debian 13 estable
curl -sL https://kodipc.serv00.net/apks/debian13-mate-postinstall.sh | sudo bash
```

```bash
# Debian Sid
curl -sL https://kodipc.serv00.net/apks/debian-sid-mate-postinstall.sh | sudo bash
```

## Requisitos

- Debian 13 (Trixie) o Debian Sid recién instalado
- Conexión a internet
- Ejecutar como root (sudo)
- Para Sid: repos con `contrib non-free non-free-firmware` habilitados

## Notas

- El script de Sid verifica que los repos tengan `non-free` y `non-free-firmware`
- Ambos scripts configuran PipeWire automáticamente para el usuario
- El tema y panel se aplican al primer inicio de sesión
- Se recomienda reiniciar después de ejecutar

## Créditos

Basado en los manuales de Richiestone.
