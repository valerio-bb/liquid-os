#!/usr/bin/env bash
set -oue pipefail

echo "==> Installazione di Cursor..."

USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"
CURSOR_URL="https://downloader.cursor.sh/linux/appImage/x64"

echo "Scaricamento di Cursor in corso..."
curl -sL -A "$USER_AGENT" -o /tmp/cursor.AppImage "$CURSOR_URL"

if [ ! -s /tmp/cursor.AppImage ]; then
    echo "Errore: Il file scaricato è vuoto."
    exit 1
fi

if head -n 1 /tmp/cursor.AppImage | grep -q "{" ; then
    echo "Errore: Risposta non valida ricevuta dal server:"
    cat /tmp/cursor.AppImage
    exit 1
fi

chmod +x /tmp/cursor.AppImage

echo "Estrazione dell'AppImage..."
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
