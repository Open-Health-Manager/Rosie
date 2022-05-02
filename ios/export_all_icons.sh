#!/bin/zsh

set -e

SIZES=(20 20@2x 20@3x 29 29@2x 29@3x 40 40@2x 40@3x 60@2x 60@3x 76 76@2x 83.5@2x 1024)
ICON_SVG=Rosie-ios-icon.svg
NAME_PREFIX=${ICON_SVG%*.svg}-

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
        # That may add a floating point component, just remove it
        size=${size%*.}
    fi
    # Maybe in the future to automatically update?
    #local output=Runner/AppIcon.appiconset/$NAME_PREFIX$name.png
    local output=$NAME_PREFIX$name.png
    if ! [ -f "$output" ] ; then
        inkscape --export-filename=$tmp_file --export-width=$size --export-height=$size $ICON_SVG
        zopflipng -m $tmp_file "$output"
    else
        echo "$output exists, skipping (delete to recreate)"
    fi
done

if [ -f "$tmp_file" ]; then
    rm "$tmp_file"
fi