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
