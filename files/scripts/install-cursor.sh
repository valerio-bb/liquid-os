#!/usr/bin/env bash
set -oue pipefail

echo "==> Installazione di Cursor in corso..."

# scriptino py
python3 - << 'EOF'
import urllib.request
import json
import sys

api_url = "https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable"
req = urllib.request.Request(
    api_url,
    headers={"User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36"}
)

try:
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read().decode())
        download_url = data.get("downloadUrl")
        if not download_url:
            print(f"Errore: downloadUrl non trovato nella risposta API: {data}")
            sys.exit(1)
        print(f"Scaricamento dal link ufficiale: {download_url}")
        urllib.request.urlretrieve(download_url, "/tmp/cursor.AppImage")
except Exception as e:
    print(f"Errore durante la chiamata API di Cursor: {e}")
    sys.exit(1)
EOF

if [ ! -s /tmp/cursor.AppImage ]; then
    echo "Errore: Il file AppImage scaricato risulta vuoto."
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
