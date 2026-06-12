#!/bin/bash
###############################################################################
# Script de post-instalación desatendida para Debian 13 (Trixie) + MATE
# Basado en los manuales de Richiestone
# Ejecutar como root: sudo bash debian13-mate-postinstall.sh
###############################################################################

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()    { echo -e "${GREEN}[OK]${NC} $*"; }
warn()   { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()  { echo -e "${RED}[ERROR]${NC} $*"; }
header() { echo -e "\n${CYAN}========================================${NC}"; echo -e "${CYAN}  $*${NC}"; echo -e "${CYAN}========================================${NC}\n"; }

###############################################################################
# 0. VERIFICACIONES PREVIAS
###############################################################################
header "Verificando requisitos previos"

if [[ $EUID -ne 0 ]]; then
    error "Este script debe ejecutarse como root (sudo)."
    exit 1
fi

REAL_USER=${SUDO_USER:-$(logname 2>/dev/null || echo "")}
if [[ -z "$REAL_USER" ]]; then
    error "No se pudo detectar el usuario real. Ejecuta con sudo."
    exit 1
fi
log "Ejecutando para el usuario: $REAL_USER"

if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    log "Detectado: $PRETTY_NAME"
fi

if ! ping -c 1 -W 3 deb.debian.org &>/dev/null; then
    error "Sin conexión a internet. Verifica tu red antes de continuar."
    exit 1
fi
log "Conexión a internet OK"

###############################################################################
# 1. REPOSITORIO MX LINUX
###############################################################################
header "Agregando repositorio MX Linux"

MX_KEYRING="mx25-archive-keyring_2025.03_all.deb"
wget -q "https://mxrepo.com/mx/repo/pool/main/m/mx25-archive-keyring/${MX_KEYRING}" -O "/tmp/${MX_KEYRING}"
dpkg -i "/tmp/${MX_KEYRING}"
rm -f "/tmp/${MX_KEYRING}"

cat > /etc/apt/sources.list.d/mx.sources << 'EOF'
Types: deb
Enabled: yes
URIs: https://mxrepo.com/mx/repo/
Suites: trixie
Components: main non-free ahs
Signed-By: /usr/share/keyrings/mx-25-archive-keyring.gpg
EOF

log "Repositorio MX Linux agregado"

###############################################################################
# 2. REPOSITORIO DEB-MULTIMEDIA
###############################################################################
header "Agregando repositorio deb-multimedia"

DMO_KEYRING="deb-multimedia-keyring_2024.9.1_all.deb"
wget -q "https://www.deb-multimedia.org/pool/main/d/deb-multimedia-keyring/${DMO_KEYRING}" -O "/tmp/${DMO_KEYRING}"
dpkg -i "/tmp/${DMO_KEYRING}"
rm -f "/tmp/${DMO_KEYRING}"

cat > /etc/apt/sources.list.d/dmo.sources << 'EOF'
Types: deb
URIs: https://www.deb-multimedia.org
Suites: trixie
Components: main non-free
Signed-By: /usr/share/keyrings/deb-multimedia-keyring.pgp
Enabled: yes

Types: deb
URIs: https://www.deb-multimedia.org
Suites: trixie-backports
Components: main
Signed-By: /usr/share/keyrings/deb-multimedia-keyring.pgp
Enabled: yes
EOF

log "Repositorio deb-multimedia agregado"

###############################################################################
# 3. ACTUALIZAR REPOSITORIOS
###############################################################################
header "Actualizando lista de paquetes"
apt update  
apt dist-upgrade -y
log "Repositorios actualizados"

###############################################################################
# 4. FIRMWARE PRINCIPAL (por si no inicia el escritorio)
###############################################################################
header "Instalando firmware principal"

apt install -y firmware-linux-nonfree firmware-amd-graphics firmware-realtek
log "Firmware principal instalado"

###############################################################################
# 5. FIRMWARE COMPLETO PARA DISPOSITIVOS DE RED Y PERIFÉRICOS
###############################################################################
header "Instalando firmware completo de red y periféricos"

apt install -y \
    firmware-ath9k-htc firmware-atheros \
    firmware-b43-installer firmware-b43legacy-installer \
    firmware-bnx2 firmware-bnx2x firmware-brcm80211 \
    firmware-intel-sound firmware-ipw2x00 firmware-iwlwifi \
    firmware-libertas firmware-misc-nonfree firmware-myricom firmware-netronome \
    firmware-netxen firmware-qlogic \
    firmware-samsung firmware-siano firmware-sof-signed \
    firmware-ti-connectivity firmware-zd1211 \
    firmware-ast firmware-cavium firmware-ivtv
log "Firmware completo instalado"

###############################################################################
# 6. UTILIDADES Y TWEAKS DEL SISTEMA
###############################################################################
header "Instalando utilidades y tweaks del sistema"

apt install -y \
    papirus-icon-theme arc-theme mate-tweak mate-menu \
    samba htop btop ttf-mscorefonts-installer gdebi ssh net-tools \
    curl wget git \
    caja-actions caja-admin caja-eiciel caja-gtkhash caja-image-converter \
    caja-mediainfo caja-open-terminal caja-rename caja-seahorse caja-sendto \
    caja-share caja-wallpaper caja-xattr-tags
log "Utilidades y tweaks installed"

###############################################################################
# 7. PIPEWIRE Y DEPENDENCIAS MULTIMEDIA
###############################################################################
header "Instalando PipeWire y plugins multimedia"

apt install -y \
    pipewire \
    pipewire-alsa \
    pipewire-audio \
    pipewire-bin \
    pipewire-pulse \
    pipewire-jack \
    pipewire-v4l2 \
    wireplumber \
    libspa-0.2-bluetooth \
    libspa-0.2-jack \
    libspa-0.2-libcamera \
    libspa-0.2-modules \
    qpwgraph \
    vlc-plugin-pipewire
log "PipeWire instalado"

###############################################################################
# 8. ACTUALIZAR PIPEWIRE, WIREPLUMBER Y LIBREOFFICE DESDE BACKPORTS
###############################################################################
header "Actualizando PipeWire, WirePlumber y LibreOffice desde backports"

apt install -t trixie-backports -y \
    pipewire \
    pipewire-alsa \
    pipewire-audio \
    pipewire-bin \
    pipewire-pulse \
    pipewire-jack \
    pipewire-v4l2 \
    wireplumber \
    libspa-0.2-bluetooth \
    libspa-0.2-jack \
    libspa-0.2-modules \
    libreoffice \
    libreoffice-l10n-es \
    libreoffice-help-es
log "PipeWire, WirePlumber y LibreOffice actualizados"

###############################################################################
# 9. KERNEL LIQUIX
###############################################################################
header "Instalando kernel Liquorix"

apt dist-upgrade -y

if ! dpkg -l | grep -q liquorix; then
    curl -s 'https://liquorix.net/install-liquorix.sh' | bash
    log "Kernel Liquorix instalado"
else
    log "Kernel Liquorix ya instalado"
fi

###############################################################################
# 10. DRIVERS AMD (64-bit + 32-bit)
###############################################################################
header "Instalando drivers AMD"

dpkg --add-architecture i386
apt update
apt install -y libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386 radeontop
log "Drivers AMD instalados"

###############################################################################
# 11. WINE
###############################################################################
header "Instalando Wine"

mkdir -pm755 /etc/apt/keyrings
wget -qO - https://dl.winehq.org/wine-builds/winehq.key | \
    gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key

cat > /etc/apt/sources.list.d/winehq-trixie.sources << 'EOF'
Types: deb
URIs: https://dl.winehq.org/wine-builds/debian
Suites: trixie
Components: main
Architectures: amd64 i386
Signed-By: /etc/apt/keyrings/winehq-archive.key
EOF

apt update
apt install --install-recommends -y winehq-stable
log "Wine instalado"

###############################################################################
# 12. BRAVE BROWSER
###############################################################################
header "Instalando Brave Browser"

curl -fsS https://dl.brave.com/install.sh | sh
log "Brave Browser instalado"

###############################################################################
# 13. ACTUALIZACIÓN FINAL
###############################################################################
header "Actualización final del sistema"

apt update
apt full-upgrade -y
log "Sistema actualizado"

###############################################################################
# 14. HABILITAR PIPEWIRE PARA EL USUARIO
###############################################################################
header "Habilitando PipeWire para $REAL_USER"

USER_UID=$(id -u "$REAL_USER")
XDG_RUNTIME_DIR="/run/user/${USER_UID}"
DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"

su - "$REAL_USER" -c "
    export XDG_RUNTIME_DIR='${XDG_RUNTIME_DIR}'
    export DBUS_SESSION_BUS_ADDRESS='${DBUS_SESSION_BUS_ADDRESS}'
    systemctl --user --now disable pulseaudio.{socket,service} || true
    systemctl --user mask pulseaudio || true
    systemctl --user --now enable pipewire{,-pulse}.{socket,service} || true
    systemctl --user --now enable wireplumber.service || true
"

log "PipeWire habilitado para $REAL_USER"

###############################################################################
# 15. KODI Y DEPENDENCIAS
###############################################################################
header "Instalando Kodi y dependencias"

apt install -t trixie-backports -y \
    kodi kodi-audiodecoder-modplug kodi-audiodecoder-openmpt \
    kodi-audiodecoder-sidplay kodi-audioencoder-flac kodi-audioencoder-lame \
    kodi-audioencoder-vorbis kodi-audioencoder-wav kodi-imagedecoder-heif \
    kodi-inputstream-adaptive kodi-inputstream-ffmpegdirect kodi-inputstream-rtmp \
    kodi-peripheral-joystick kodi-pvr-iptvsimple kodi-vfs-libarchive \
    kodi-vfs-rar kodi-vfs-sftp retroarch openrct2
log "Kodi instalado"

###############################################################################
# 16. PROGRAMAS DE DISEÑO GRÁFICO Y MULTIMEDIA
###############################################################################
header "Instalando programas de diseño gráfico y multimedia"

apt install -t trixie-backports -y \
    inkscape inkscape-open-symbols inkscape-speleo inkscape-survex-export \
    inkscape-textext inkscape-textext-doc krita krita-l10n \
    gimp gimp-data-extras scribus scribus-doc scribus-template \
    darktable openshot-qt audacity dvdstyler simplescreenrecorder \
    guvcview amule filezilla qbittorrent blender clipgrab
log "Programas de diseño y multimedia instalados"

###############################################################################
# 17. HERRAMIENTAS DE SEGURIDAD / AUDITORÍA
###############################################################################
header "Instalando herramientas de auditoría de redes"

apt install -y wifite bully hashcat hcxdumptool hcxtools wireshark macchanger
log "Herramientas de seguridad instaladas"

###############################################################################
# 18. AUTOLOGIN EN LIGHTDM
###############################################################################
header "Configurando autologin en LightDM"

mkdir -p /etc/lightdm/lightdm.conf.d
cat > /etc/lightdm/lightdm.conf.d/01-autologin.conf << EOF
[Seat:*]
autologin-user=${REAL_USER}
autologin-user-timeout=0
EOF

log "Autologin configurado para $REAL_USER"

###############################################################################
# 19. LIMPIEZA FINAL
###############################################################################
header "Limpieza final"

apt autoremove -y
apt autoclean
log "Limpieza completada"

###############################################################################
# 20. APLICAR TEMA, ICONOS, PANEL Y CONFIGURACIÓN DEL ESCRITORIO
###############################################################################
header "Aplicando tema, iconos, panel y configuración del escritorio"

# Crear script de autostart que aplicará la configuración al iniciar sesión
su - "$REAL_USER" -c '
    FLAG="$HOME/.config/mate-panel-configured"

    mkdir -p "$HOME/.config/autostart"
    cat > "$HOME/.config/autostart/mate-panel-setup.desktop" << "DESKTOP"
[Desktop Entry]
Type=Application
Name=MATE Panel Setup
Exec=$HOME/.local/bin/mate-panel-setup.sh
Hidden=false
NoDisplay=true
X-MATE-Autostart-enabled=true
DESKTOP

    mkdir -p "$HOME/.local/bin"
    cat > "$HOME/.local/bin/mate-panel-setup.sh" << "SCRIPT"
#!/bin/bash
FLAG="$HOME/.config/mate-panel-configured"
if [ -f "$FLAG" ]; then
    exit 0
fi

sleep 3

dbus-launch dconf load /org/mate/ << MATECONF
[desktop/interface]
gtk-theme="Arc-Dark"
icon-theme="Papirus-Dark"

[marco/general]
theme="Arc-Dark"
num-workspaces=1

[desktop/background]
picture-filename="/usr/share/backgrounds/cosmos/background-1.xml"
picture-options="zoom"
color-shading-type="vertical-gradient"
primary-color="rgb(88,145,188)"
secondary-color="rgb(60,143,37)"

[desktop/sound]
event-sounds=true
theme-name="freedesktop"

[desktop/peripherals/mouse]
cursor-theme="mate-black"

[panel/toplevels/top]
expand=true
orientation="top"
screen=0
size=32

[panel/objects/clock]
applet-iid="ClockAppletFactory::ClockApplet"
locked=true
object-type="applet"
position=0
relative-to-edge="end"
toplevel-id="top"

[panel/objects/notification-area]
applet-iid="NotificationAreaAppletFactory::NotificationArea"
locked=true
object-type="applet"
position=10
relative-to-edge="end"
toplevel-id="top"

[panel/objects/object-0]
object-type="menu"
position=5
tooltip="Menú compacto"
toplevel-id="top"
use-menu-path=false

[panel/objects/object-1]
applet-iid="WnckletFactory::WindowListApplet"
object-type="applet"
position=121
toplevel-id="top"

[panel/objects/object-2]
launcher-location="/usr/share/applications/brave-browser.desktop"
object-type="launcher"
position=27
toplevel-id="top"

[panel/objects/object-3]
launcher-location="/usr/share/applications/mate-terminal.desktop"
object-type="launcher"
position=61
toplevel-id="top"

[panel/objects/object-4]
launcher-location="/usr/share/applications/caja-browser.desktop"
object-type="launcher"
position=88
toplevel-id="top"

[panel/objects/object-5]
applet-iid="MultiLoadAppletFactory::MultiLoadApplet"
object-type="applet"
position=1479
toplevel-id="top"

[panel/objects/object-6]
applet-iid="NetspeedAppletFactory::NetspeedApplet"
object-type="applet"
position=1434
toplevel-id="top"
MATECONF

rm -f "$HOME/.config/autostart/mate-panel-setup.desktop"
rm -f "$HOME/.local/bin/mate-panel-setup.sh"
touch "$FLAG"
mate-panel --replace &
SCRIPT

    chmod +x "$HOME/.local/bin/mate-panel-setup.sh"
'

log "Tema Arc-Dark, iconos Papirus-Dark y panel configurado"

###############################################################################
# FIN
###############################################################################
header "INSTALACIÓN COMPLETADA"

echo ""
log "Todo instalado correctamente."
echo ""
warn "Se recomienda REINICIAR para aplicar el kernel Liquorix y todos los cambios."
echo ""
echo "  sudo reboot"
echo ""
