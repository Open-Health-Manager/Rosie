#!/bin/zsh

# This script handles exporting all the various icons from the app.
# It requires that Inkscape (https://inkscape.org/) and zopflipng (part of
# zopfli: https://github.com/google/zopfli) be installed to use.
# These can easily be installed via Homebrew/Homebrew casks (https://brew.sh/):
#
#     brew install inkscape zopfli

set -e

# Set defaults
ICON_SVG=Rosie-ios-icon.svg
OUTPUT_DIR=Assets.xcassets/AppIcon.appiconset

# If there are input variables, use them.
if (($# >= 1)) ; then
    ICON_SVG="$1"
    shift
fi
if (($# >= 1)); then
    OUTPUT_DIR="$1"
    shift
fi

if ! [ -d $OUTPUT_DIR ] ; then
    echo "error: cannot output to $OUTPUT_DIR: it does not exist or is not a directory" >&2
    exit 1
fi

SIZES=(20 20@2x 20@3x 29 29@2x 29@3x 40 40@2x 40@3x 60@2x 60@3x 76 76@2x 83.5@2x 1024)
NAME_PREFIX=`basename $ICON_SVG`
NAME_PREFIX=${NAME_PREFIX%*.svg}-

echo "note: converting $ICON_SVG to ${#SIZES[@]} output PNGs in $OUTPUT_DIR"

local tmp_file="inkscape-export.png"

for size in $SIZES; do
    # See if there's a scalar factor
    local scale=1
    local name=${size}x$size
    if [ ${size#*@} != $size ]; then
        scale=${size#*@}
        scale=${scale%*x}
        size=${size%@*}
        name=${size}x$size@${scale}x
        (( size=$size * $scale ))
        # That may add a floating point component, just remove it to effectively
        # "floor" any decimal parts. It should always be 0, this is for 83.5@2x
        # which becomes 167.0.
        size=${size%*.}
    fi
    local output="$OUTPUT_DIR/$NAME_PREFIX$name.png"
    if (! [ -f "$output" ]) || [ "$ICON_SVG" -nt "$output" ] ; then
        inkscape --export-filename=$tmp_file --export-width=$size --export-height=$size $ICON_SVG
        # zopflipng doesn't have an overwrite option
        if [ -f "$output" ] ; then
            rm "$output"
        fi
        zopflipng -m $tmp_file "$output"
    else
        echo "note: skipping $output (up to date)"
    fi
done

if [ -f "$tmp_file" ]; then
    rm "$tmp_file"
fi