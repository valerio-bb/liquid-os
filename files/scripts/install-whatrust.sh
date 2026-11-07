#!/usr/bin/env bash

set -oue pipefail
echo "==> Installazione di whatRust..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/karem505/whatRust/releases/latest | grep "browser_download_url.*flatpak" | cut -d '"' -f 4)

if [ -n "$DOWNLOAD_URL" ]; then
    echo "Scaricamento del bundle da: $DOWNLOAD_URL"
    curl -L -o /tmp/whatRust.flatpak "$DOWNLOAD_URL"
    flatpak install --system --assumeyes --noninteractive /tmp/whatRust.flatpak
    rm -f /tmp/whatRust.flatpak
else
    echo "Errore: Impossibile trovare il file flatpak nelle release di GitHub."
    exit 1
fi

echo "==> whatRust installato con successo!"
