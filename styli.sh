#!/usr/bin/env bash
# shellcheck disable=SC2120,SC1090,SC2154,SC2034
# SC2120: foo references arguments, but none are ever passed.
# SC1090: Can't follow non-constant source. Use a directive to specify location.
# SC2154: var is referenced but not assigned.
# SC2034: foo appears unused. Verify it or export it.


LINK="https://source.unsplash.com/random/"

if [ -z ${XDG_CONFIG_HOME+x} ]; then
    XDG_CONFIG_HOME="$HOME/.config"
fi
if [ -z ${XDG_CACHE_HOME+x} ]; then
    XDG_CACHE_HOME="$HOME/.cache"
fi
CONFDIR="${XDG_CONFIG_HOME}/styli.sh"
if [ ! -d "$CONFDIR" ]; then
    mkdir -p "$CONFDIR"
fi
CACHEDIR="${XDG_CACHE_HOME}/styli.sh"
if [ ! -d "$CACHEDIR" ]; then
    mkdir -p "$CACHEDIR"
fi

WALLPAPER="$CACHEDIR/wallpaper.jpg"

save_cmd() {
    cp "$WALLPAPER" "$HOME/Pictures/wallpaper$RANDOM.jpg"
}

die() {
    printf "ERR: %s\n" "$1" >&2
    exit 1
}

# https://github.com/egeesin/alacritty-color-export
alacritty_change() { #SC2120
    DEFAULT_MACOS_CONFIG="$HOME"/.config/alacritty/alacritty.yml

    # Wal generates a shell script that defines color0..color15
    SRC="$HOME"/.cache/wal/colors.sh

    [ -e "$SRC" ] || die "Wal colors not found, exiting script. Have you executed Wal before?"
    printf "Colors found, source ready.\n"

    READLINK=$(command -v greadlink || command -v readlink)

    # Get config file
    if [ -n "$1" ]; then
        [ -e "$1" ] || die "Selected config doesn't exist, exiting script."
        printf "Config found, destination ready.\n"
        CFG="$1"
        [ -L "$1" ] && {
            printf "Following symlink to config...\n"
            CFG=$("$READLINK" -f "$1")
        }
    else
        # Default config path in Mac systems
        [ -e "$DEFAULT_MACOS_CONFIG" ] || die "Alacritty config not found, exiting script."

        CFG="$DEFAULT_MACOS_CONFIG"
        [ -L "$DEFAULT_MACOS_CONFIG" ] && {
            printf "Following symlink to config...\n"
            CFG=$("$READLINK" -f "$DEFAULT_MACOS_CONFIG")
        }
    fi

    # Get hex colors from Wal cache
    # No need for shellcheck to check this, it comes from pywal
    . "$SRC" #SC1090

    # Create temp file for sed results
    TEMPFILE=$(mktemp)
    trap 'rm $TEMPFILE' INT TERM EXIT

    # Delete existing color declarations generated by this script
    # If begin comment exists
    if grep -q '^# BEGIN ACE' "$CFG"; then
        # And if end comment exists
        if grep -q '^# END ACE' "$CFG"; then
            # Delete contents of the block
            printf "Existing generated colors found, replacing new colors...\n"
            sed '/^# BEGIN ACE/,/^# END ACE/ {
        /^# BEGIN ACE/! { /^# END ACE/!d; }
            }' "$CFG" >"$TEMPFILE" &&
                cat "$TEMPFILE" >"$CFG"
            # If no end comment, don't do anything
        else
            die "No '# END ACE' comment found, please ensure it is present."
        fi
        # If no begin comment found
    else
        # Don't do anything and notify user if there's an end comment in the file
        ! grep -q '^# END ACE' "$CFG" || die "Found '# END ACE' comment, but no '# BEGIN ACE' comment found. Please ensure it is present."
        printf "There's no existing 'generated' colors, adding comments...\n"
        printf '# BEGIN ACE\n# END ACE' >>"$CFG"
    fi

    # Write new color definitions
    # We know $colorX is unset, we set it by sourcing above
    # SC2154
    {
        sed "/^# BEGIN ACE/ r /dev/stdin" "$CFG" >"$TEMPFILE" <<EOP
colors:
  primary:
    background: '$color0'
    foreground: '$color7'
  cursor:
    text:       '$color0'
    cursor:     '$color7'
  normal:
    black:      '$color0'
    red:        '$color1'
    green:      '$color2'
    yellow:     '$color3'
    blue:       '$color4'
    magenta:    '$color5'
    cyan:       '$color6'
    white:      '$color7'
  bright:
    black:      '$color8'
    red:        '$color9'
    green:      '$color10'
    yellow:     '$color11'
    blue:       '$color12'
    magenta:    '$color13'
    cyan:       '$color14'
    white:      '$color15'
EOP
    } && cat "$TEMPFILE" >"$CFG" &&
        rm "$TEMPFILE"
    trap - INT TERM EXIT
    printf "'%s' exported to '%s'\n" "$SRC" "$CFG"
}

reddit() {
    USERAGENT="thevinter"
    TIMEOUT=60

    SORT="$2"
    TOP_TIME="$3"
    if [ -z "$SORT" ]; then
        SORT="hot"
    fi

    if [ -z "$TOP_TIME" ]; then
        TOP_TIME=""
    fi

    if [ -n "$1" ]; then
        SUB="$1"
    else
        if [ ! -f "$CONFDIR/subreddits" ]; then
            echo "Please install the subreddits file in $CONFDIR"
            exit 2
        fi
        mapfile -t SUBREDDITS <"$CONFDIR/subreddits"
        a=${#SUBREDDITS[@]}
        b=$((RANDOM % a))
        SUB=${SUBREDDITS[$b]}
        SUB="$(echo -e "$SUB" | tr -d '[:space:]')"
    fi

    URL="https://www.reddit.com/r/$SUB/$SORT/.json?raw_json=1&t=$TOP_TIME"
    CONTENT=$(wget -T $TIMEOUT -U "$USERAGENT" -q -O - "$URL")
    mapfile -t URLS <<<"$(echo -n "$CONTENT" | jq -r '.data.children[]|select(.data.post_hint|test("image")?) | .data.preview.images[0].source.url')"
    wait # prevent spawning too many processes
    SIZE=${#URLS[@]}
    if [ "$SIZE" -eq 0 ]; then
        echo The current subreddit is not valid.
        exit 1
    fi
    IDX=$((RANDOM % SIZE))
    # TARGET_NAME, TARGET_ID, EXT and NEWNAME are not used
    # mapfile -t IDS <<<"$(echo -n "$CONTENT" | jq -r '.data.children[]|select(.data.post_hint|test("image")?) | .data.id')"
    # mapfile -t NAMES <<<"$(echo -n "$CONTENT" | jq -r '.data.children[]|select(.data.post_hint|test("image")?) | .data.title')"
    TARGET_URL=${URLS[$IDX]}
    # TARGET_NAME=${NAMES[$IDX]}
    # TARGET_ID=${IDS[$IDX]}
    # EXT=$(echo -n "${TARGET_URL##*.}" | cut -d '?' -f 1)
    # NEWNAME=$(echo "$TARGET_NAME" | sed "s/^\///;s/\// /g")_"$SUBREDDIT"_$TARGET_ID.$EXT
    wget -T $TIMEOUT -U "$USERAGENT" --no-check-certificate -q -P down -O "$WALLPAPER" "$TARGET_URL" &>/dev/null
}

unsplash() {
    local SEARCH="${SEARCH// /+}"
    if [ -n "$HEIGHT" ] || [ -n "$WIDTH" ]; then
        LINK="${LINK}${WIDTH}x${HEIGHT}" # dont remove {} from variables
    else
        LINK="${LINK}1920x1080"
    fi

    if [ -n "$SEARCH" ]; then
        LINK="${LINK}/?${SEARCH}"
    fi

    wget -q -O "$WALLPAPER" "$LINK"
}

deviantart() {
    CLIENT_ID=16531
    CLIENT_SECRET=68c00f3d0ceab95b0fac638b33a3368e
    PAYLOAD="grant_type=client_credentials&client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}"
    ACCESS_TOKEN=$(curl --silent -d $PAYLOAD https://www.deviantart.com/oauth2/token | jq -r '.access_token')
    if [ -n "$1" ]; then
        ARTIST=$1
        URL="https://www.deviantart.com/api/v1/oauth2/gallery/?username=$ARTIST&mode=popular&limit=24"
    elif [ -n "$SEARCH" ]; then
        [[ "$SEARCH" =~ ^(tag:)(.*)$ ]] && TAG=${BASH_REMATCH[2]}
        if [ -n "$TAG" ]; then
            URL="https://www.deviantart.com/api/v1/oauth2/browse/tags?tag=$TAG&offset=${RANDOM:0:2}&limit=24"
        else
            URL="https://www.deviantart.com/api/v1/oauth2/browse/popular?q=$SEARCH&limit=24&timerange=1month"
        fi
    else
        #URL="https://www.deviantart.com/api/v1/oauth2/browse/hot?limit=24&offset=$OFFSET"
        TOPICS=("adoptables" "artisan-crafts" "anthro" "comics" "drawings-and-paintings" "fan-art" "poetry" "stock-images" "sculpture" "science-fiction" "traditional-art" "street-photography" "street-art" "pixel-art" "wallpaper" "digital-art" "photo-manipulation" "science-fiction" "fractal" "game-art" "fantasy" "3d" "drawings-and-paintings" "game-art")
        RAND=$((RANDOM % ${#topics[@]}))
        URL="https://www.deviantart.com/api/v1/oauth2/browse/topic?limit=24&topic=${TOPICS[$RAND]}"
    fi
    CONTENT=$(curl --silent -H "Authorization: Bearer ${ACCESS_TOKEN}" -H "Accept: application/json" -H "Content-Type: application/json" "$URL")
    mapfile -t URLS <<<"$(echo -n "$CONTENT" | jq -r '.results[].content.src')"
    SIZE=${#URLS[@]}
    IDX=$((RANDOM % SIZE))
    TARGET_URL=${ARRURLS[$IDX]}
    wget --no-check-certificate -q -P down -O "$WALLPAPER" "$TARGET_URL" &>/dev/null
}

usage() {
    echo "Usage: styli.sh [-s | --search <string>]
    [-h | --height <height>]
    [-w | --width <width>]
    [-b | --fehbg <feh bg opt>]
    [-c | --fehopt <feh opt>]
    [-a | --artist <deviant artist>]
    [-r | --subreddit <subreddit>]
    [-l | --link <source>]
    [-p | --termcolor]
    [-L | --lightwal]
    [-d | --directory]
    [-k | --kde]
    [-x | --xfce]
    [-g | --gnome]
    [-m | --monitors <monitor count (nitrogen)>]
    [-n | --nitrogen]
    [-sa | --save]    <Save current image to pictures directory>
    "
    exit 2
}

type_check() {
    MIME_TYPES=("image/bmp" "image/jpeg" "image/gif" "image/png" "image/heic")
    ISTYPE=false

    for REQUIREDTYPE in "${MIME_TYPES[@]}"; do
        IMAGETYPE=$(file --mime-type "$WALLPAPER" | awk '{print $2}')
        if [ "$REQUIREDTYPE" = "$IMAGETYPE" ]; then
            ISTYPE=true
            break
        fi
    done

    if [ $ISTYPE = false ]; then
        echo "MIME-Type missmatch. Downloaded file is not an image!"
        exit 1
    fi
}

select_random_wallpaper() {
    WALLPAPER=$(find "$DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.svg" -o -iname "*.gif" \) -print | shuf -n 1)
}

pywal_cmd() {

    if [ "$PYWAL" -eq 1 ]; then
        wal -c
        wal -i "$WALLPAPER" -n -q
        if [ "$TERM" = alacritty ]; then
            alacritty_change
        fi
    fi

    if [ "$LIGHT" -eq 1 ]; then
        wal -c
        wal -i "$WALLPAPER" -n -q -l
        if [ "$TERM" = alacritty ]; then
            alacritty_change
        fi
    fi

}

sway_cmd() {
    if [ -n "$BGTYPE" ]; then
        if [ "$BGTYPE" == 'bg-center' ]; then
            MODE="center"
        fi
        if [ "$BGTYPE" == 'bg-fill' ]; then
            MODE="fill"
        fi
        if [ "$BGTYPE" == 'bg-max' ]; then
            MODE="fit"
        fi
        if [ "$BGTYPE" == 'bg-scale' ]; then
            MODE="stretch"
        fi
        if [ "$BGTYPE" == 'bg-tile' ]; then
            MODE="tile"
        fi
    else
        MODE="stretch"
    fi
    swaymsg output "*" bg "$WALLPAPER" "$MODE"

}

nitrogen_cmd() {
    for ((MONITOR = 0; monitor < "$MONITORS"; monitor++)); do
        local NITROGEN_ARR=(nitrogen --save --head="$MONITOR")

        if [ -n "$BGTYPE" ]; then
            if [ "$BGTYPE" == 'bg-center' ]; then
                NITROGEN_ARR+=(--set-centered)
            fi
            if [ "$BGTYPE" == 'bg-fill' ]; then
                NITROGEN_ARR+=(--set-zoom-fill)
            fi
            if [ "$BGTYPE" == 'bg-max' ]; then
                NITROGEN_ARR+=(--set-zoom)
            fi
            if [ "$BGTYPE" == 'bg-scale' ]; then
                NITROGEN_ARR+=(--set-scaled)
            fi
            if [ "$BGTYPE" == 'bg-tile' ]; then
                NITROGEN_ARR+=(--set-tiled)
            fi
        else
            NITROGEN_ARR+=(--set-scaled)
        fi

        if [ -n "$CUSTOM" ]; then
            NITROGEN_ARR+=("$CUSTOM")
        fi

        NITROGEN_ARR+=("$WALLPAPER")

        "${NITROGEN_ARR[@]}"
    done
}

kde_cmd() {
    cp "$WALLPAPER" "$CACHEDIR/tmp.jpg"
    qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "var allDesktops = desktops();print (allDesktops);for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.wallpaperPlugin = \"org.kde.image\";d.currentConfigGroup = Array(\"Wallpaper\", \"org.kde.image\", \"General\");d.writeConfig(\"Image\", \"file:$CACHEDIR/tmp.jpg\")}"
    qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "var allDesktops = desktops();print (allDesktops);for (i=0;i<allDesktops.length;i++) {d = allDesktops[i];d.wallpaperPlugin = \"org.kde.image\";d.currentConfigGroup = Array(\"Wallpaper\", \"org.kde.image\", \"General\");d.writeConfig(\"Image\", \"file:$WALLPAPER\")}"
    sleep 5 && rm "$CACHEDIR/tmp.jpg"
}

xfce_cmd() {
    ## CONNECTEDOUTPUTS ACTIVEOUTPUT and CONNECTED are not used
    # CONNECTEDOUTPUTS=$(xrandr | grep " connected" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
    # ACTIVEOUTPUT=$(xrandr | grep -e " connected [^(]" | sed -e "s/\([A-Z0-9]\+\) connected.*/\1/")
    # CONNECTED=$(echo "$CONNECTEDOUTPUTS" | wc -w)

    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -n -t string -s ~/Pictures/1.jpeg
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorLVDS1/workspace0/last-image -n -t string -s ~/Pictures/1.jpeg

    for i in $(xfconf-query -c xfce4-desktop -p /backdrop -l | grep -E -e "screen.*/monitor.*image-path$" -e "screen.*/monitor.*/last-image$"); do
        xfconf-query -c xfce4-desktop -p "$i" -n -t string -s "$WALLPAPER"
        xfconf-query -c xfce4-desktop -p "$i" -s "$WALLPAPER"
    done
}

gnome_cmd() {
    gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER"
}

feh_cmd() {
    local FEH
    FEH=(feh)
    if [ -n "$BGTYPE" ]; then
        if [ "$BGTYPE" == 'bg-center' ]; then
            FEH+=(--bg-center)
        fi
        if [ "$BGTYPE" == 'bg-fill' ]; then
            FEH+=(--bg-fill)
        fi
        if [ "$BGTYPE" == 'bg-max' ]; then
            FEH+=(--bg-max)
        fi
        if [ "$BGTYPE" == 'bg-scale' ]; then
            FEH+=(--bg-scale)
        fi
        if [ "$BGTYPE" == 'bg-tile' ]; then
            FEH+=(--bg-tile)
        fi
    else
        FEH+=(--bg-scale)
    fi

    if [ -n "$CUSTOM" ]; then
        FEH+=("$CUSTOM")
    fi

    FEH+=("$WALLPAPER")

    "${FEH[@]}"
}

PYWAL=0
LIGHT=0
KDE=false
XFCE=false
GNOME=false
NITROGEN=false
SWAY=false
MONITORS=1
# SC2034
PARSED_ARGUMENTS=$(getopt -a -n "$0" -o h:w:s:l:b:r:a:c:d:m:pLknxgy:sa --long search:,height:,width:,fehbg:,fehopt:,artist:,subreddit:,directory:,monitors:,termcolor:,lighwal:,kde,nitrogen,xfce,gnome,sway,save -- "$@")

VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
    usage
    exit
fi
while :; do
    case "${1}" in
    -b | --fehbg)
        BGTYPE=${2}
        shift 2
        ;;
    -s | --search)
        SEARCH=${2}
        shift 2
        ;;
    -sa | --save)
        SAVE=true
        shift
        ;;
    -h | --height)
        HEIGHT=${2}
        shift 2
        ;;
    -w | --width)
        WIDTH=${2}
        shift 2
        ;;
    -l | --link)
        LINK=${2}
        shift 2
        ;;
    -r | --subreddit)
        SUB=${2}
        shift 2
        ;;
    -a | --artist)
        ARTIST=${2}
        shift 2
        ;;
    -c | --fehopt)
        CUSTOM=${2}
        shift 2
        ;;
    -m | --monitors)
        MONITORS=${2}
        shift 2
        ;;
    -n | --nitrogen)
        NITROGEN=true
        shift
        ;;
    -d | --directory)
        DIR=${2}
        shift 2
        ;;
    -p | --termcolor)
        PYWAL=1
        shift
        ;;
    -L | --lightwal)
        LIGHT=1
        shift
        ;;
    -k | --kde)
        KDE=true
        shift
        ;;
    -x | --xfce)
        XFCE=true
        shift
        ;;
    -g | --gnome)
        GNOME=true
        shift
        ;;
    -y | --sway)
        SWAY=true
        ;;
    -- | '')
        SWAY=true
        break
        ;;
    *)
        echo "Unexpected option: $1 - this should not happen."
        usage
        ;;
    esac
done

if [ -n "$DIR" ]; then
    select_random_wallpaper
elif [ "$LINK" = "reddit" ] || [ -n "$SUB" ]; then
    reddit "$SUB"
elif [ "$LINK" = "deviantart" ] || [ -n "$ARTIST" ]; then
    deviantart "$ARTIST"
elif [ -n "$SAVE" ]; then
    save_cmd
else
    unsplash
fi

type_check

if [ "$KDE" = true ]; then
    kde_cmd
elif [ "$XFCE" = true ]; then
    xfce_cmd
elif [ "$GNOME" = true ]; then
    gnome_cmd
elif [ "$NITROGEN" = true ]; then
    nitrogen_cmd
elif [ "$SWAY" = true ]; then
    sway_cmd
else
    feh_cmd >/dev/null 2>&1
fi

pywal_cmd