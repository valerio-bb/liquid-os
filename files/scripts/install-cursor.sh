#!/usr/bin/env bash
set -oue pipefail

echo "==> Installazione di Cursor in corso..."

# scriptino py
python3 - << 'EOF'
import urllib.request
import json
import sys

api_url = "https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=stable"
headers = {"User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36"}

try:
    req_api = urllib.request.Request(api_url, headers=headers)
    with urllib.request.urlopen(req_api) as response:
        data = json.loads(response.read().decode())
        download_url = data.get("downloadUrl")
        if not download_url:
            print(f"Errore: downloadUrl non trovato nella risposta API: {data}")
            sys.exit(1)
        print(f"Scaricamento dal link ufficiale: {download_url}")

    req_download = urllib.request.Request(download_url, headers=headers)
    with urllib.request.urlopen(req_download) as response, open("/tmp/cursor.AppImage", "wb") as out_file:
        while True:
            chunk = response.read(8192)
            if not chunk:
                break
            out_file.write(chunk)

except Exception as e:
    print(f"Errore durante il download di Cursor: {e}")
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

mkdir -p /usr/local/bin
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
