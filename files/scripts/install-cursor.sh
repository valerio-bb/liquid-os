#!/usr/bin/env bash
set -oue pipefail

echo "==> Installazione di Cursor..."

CURSOR_URL="https://downloader.cursor.sh/linux/appImage/x64"

curl -L -o /tmp/cursor.AppImage "$CURSOR_URL"
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
