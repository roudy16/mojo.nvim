#!/usr/bin/env bash
# make-demo-gif.sh
#
# Creates a demo GIF from a screen recording. Each entry in specs.txt
# becomes a short animated clip with an overlay description.
#
# Usage:
#   ./scripts/make-demo-gif.sh <directory> [fps] [width]
#
#   <directory>  must contain video.mov and specs.txt
#   fps          frames per second (default: 12)
#   width        max width in pixels (default: 640)
#
# Example specs.txt:
#   00:05|00:09|Code completion
#   00:12|00:16|Hover documentation
#
# Requires: ffmpeg, magick (ImageMagick 7+)

set -euo pipefail

DIR="${1:-}"
FPS="${2:-4}"
MAX_WIDTH="${3:-800}"

if [ -z "$DIR" ]; then
	echo "Usage: $0 <directory> [fps] [width]"
	exit 1
fi

INPUT="$DIR/video.mov"
SPECS="$DIR/specs.txt"
OUTPUT="$DIR/demo.gif"

[ -f "$INPUT" ] || {
	echo "Error: $INPUT not found"
	exit 1
}
[ -f "$SPECS" ] || {
	echo "Error: $SPECS not found"
	exit 1
}

command -v ffmpeg &>/dev/null || {
	echo "Error: install ffmpeg"
	exit 1
}
command -v magick &>/dev/null || {
	echo "Error: install ImageMagick"
	exit 1
}

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

VIDEO_DUR=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$INPUT" 2>/dev/null)
VIDEO_DUR=${VIDEO_DUR%.*}
echo "Video duration: ${VIDEO_DUR}s"

TEXT_COLOR="white"
TEXT_BG="rgba(0,0,0,0.75)"
FONT="/System/Library/Fonts/Helvetica.ttc"

ALL_FRAMES=()

echo "Processing clips..."

while IFS='|' read -r START END LABEL; do
	START=$(echo "$START" | xargs)
	END=$(echo "$END" | xargs)
	[ -z "$START" ] && continue

	SAFE=$(echo "$LABEL" | tr ' ' '_' | tr -cd '[:alnum:]_')
	CLIP_DIR="$TMPDIR/${SAFE}"
	mkdir -p "$CLIP_DIR"

	echo "  $START-$END → $LABEL"

	S_SEC=$(echo "$START" | awk -F: '{ print ($1*60)+$2 }')
	E_SEC=$(echo "$END" | awk -F: '{ print ($1*60)+$2 }')
	NUM_FRAMES=$(((E_SEC - S_SEC) * FPS))
	if [ "$S_SEC" -ge "$VIDEO_DUR" ]; then
		echo "    (past end of video, skipping)"
		continue
	fi
	if [ "$NUM_FRAMES" -le 0 ]; then
		echo "    (invalid times, skipping)"
		continue
	fi

	ffmpeg -nostdin -y -i "$INPUT" -ss "$START" \
		-vf "fps=$FPS,scale=$MAX_WIDTH:-1:flags=lanczos" \
		-frames:v "$NUM_FRAMES" \
		"$CLIP_DIR/f_%04d.png" 2>/dev/null

	FRAMES=$(ls "$CLIP_DIR"/f_*.png 2>/dev/null | sort)
	COUNT=$(echo "$FRAMES" | wc -l | tr -d ' ')
	[ "$COUNT" -eq 0 ] && {
		echo "    (no frames)"
		continue
	}

	FIRST=$(echo "$FRAMES" | head -1)
	H=$(magick identify -format "%h" "$FIRST")

	BAR_H=$((H / 10))
	BAR_Y=$(((H * 3 / 4) - (BAR_H / 2)))
	PT=$((H / 30))
	TEXT_Y=$(((H / 4) - (PT / 4)))

	for f in $FRAMES; do
		labeled="${f%.png}_l.png"
		magick "$f" \
			-fill "$TEXT_BG" \
			-draw "rectangle 0,${BAR_Y} ${MAX_WIDTH},$((BAR_Y + BAR_H))" \
			-fill "$TEXT_COLOR" \
			-font "$FONT" \
			-pointsize "$PT" \
			-gravity center \
			-annotate "+0+${TEXT_Y}" "$LABEL" \
			"$labeled"
		ALL_FRAMES+=("$labeled")
	done
done <"$SPECS"

TOTAL=${#ALL_FRAMES[@]}
if [ "$TOTAL" -eq 0 ]; then
	echo "Error: no frames extracted"
	exit 1
fi

# Remove old GIF if it exists
[ -f "$OUTPUT" ] && rm "$OUTPUT"

echo "Creating GIF ($TOTAL frames) at ${FPS}fps ${MAX_WIDTH}px..."
DELAY=$((100 / FPS))
CMD=(magick)
for f in "${ALL_FRAMES[@]}"; do
	CMD+=(-delay "$DELAY" "$f")
done
CMD+=(-loop 0 "$OUTPUT")
"${CMD[@]}"

if command -v gifsicle &>/dev/null; then
	gifsicle -O1 --colors 192 "$OUTPUT" -o "$OUTPUT"
fi

echo "Done! GIF saved to: $OUTPUT"
