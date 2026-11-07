#!/usr/bin/env bash
set -oue pipefail

echo "==> Installazione di Cursor..."

DOWNLOAD_URL=$(curl -s "https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable" | grep -oE '"downloadUrl":"[^"]+' | cut -d'"' -f4)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "Errore critico: Impossibile recuperare l'URL di download di Cursor dall'API."
    exit 1
fi

echo "Scaricamento di Cursor da: $DOWNLOAD_URL"
curl -L -o /tmp/cursor.AppImage "$DOWNLOAD_URL"
chmod +x /tmp/cursor.AppImage

cd /tmp
./cursor.AppImage --appimage-extract > /dev/null

mkdir -p /usr/lib/cursor
cp -r /tmp/squashfs-root/* /usr/lib/cursor/

ln -sf /usr/lib/cursor/cursor /usr/local/bin/cursor

mkdir -p /usr/share/applications
cat << 'EOF' > /usr/share/applications/cursor.desktop
[Desktop Entry]
Name=Cursor
Exec=/usr/local/bin/cursor %F
Icon=/usr/lib/cursor/cursor.png
Type=Application
Categories=Development;IDE;
Terminal=false
MimeType=text/plain;inode/directory;
EOF

rm -rf /tmp/cursor.AppImage /tmp/squashfs-root

echo "==> Cursor installato con successo!"
