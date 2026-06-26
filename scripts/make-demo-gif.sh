#!/usr/bin/env bash
# make-demo-gif.sh
#
# Creates a demo GIF from a screen recording with overlay descriptions.
#
# Usage:
#   ./scripts/make-demo-gif.sh <directory>
#
# The directory must contain:
#   video.mov    — screen recording
#   specs.txt    — one frame per line:  start|end|Description
#
# Example specs.txt:
#   00:05|00:08|Code completion
#   00:12|00:15|Hover documentation
#   00:20|00:25|Go to definition
#
# Requires: ffmpeg, magick (ImageMagick 7+)

set -euo pipefail

DIR="${1:-}"
if [ -z "$DIR" ]; then
	echo "Usage: $0 <directory>"
	echo ""
	echo "  The directory must contain video.mov and specs.txt"
	exit 1
fi

INPUT="$DIR/video.mov"
SPECS="$DIR/specs.txt"
OUTPUT="$DIR/demo.gif"

if [ ! -f "$INPUT" ]; then
	echo "Error: $INPUT not found"
	exit 1
fi
if [ ! -f "$SPECS" ]; then
	echo "Error: $SPECS not found"
	exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
	echo "Error: ffmpeg not found. Install with: brew install ffmpeg"
	exit 1
fi
if ! command -v magick &> /dev/null; then
	echo "Error: ImageMagick not found. Install with: brew install imagemagick"
	exit 1
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

TEXT_COLOR="white"
TEXT_BG="rgba(0,0,0,0.6)"
FONT="/System/Library/Fonts/Helvetica.ttc"

FRAME_FILES=()
DELAYS=()

echo "Processing specs..."
while IFS='|' read -r START END LABEL; do
	# Trim whitespace
	START=$(echo "$START" | xargs)
	END=$(echo "$END" | xargs)
	LABEL=$(echo "$LABEL" | xargs)

	[ -z "$START" ] && continue

	echo "  $START → $LABEL"

	SAFE=$(echo "$LABEL" | tr ' ' '_' | tr -cd '[:alnum:]_')
	RAW="${TMPDIR}/${SAFE}.png"
	LABELED="${TMPDIR}/${SAFE}_labeled.png"

	# Extract frame at start timestamp
	ffmpeg -y -ss "$START" -i "$INPUT" -vframes 1 -q:v 1 "$RAW" 2>/dev/null

	# Calculate delay: (end - start) in seconds * 100
	# ffmpeg timestamp to seconds helper
	S_SEC=$(echo "$START" | awk -F: '{ print ($1*60)+$2 }')
	E_SEC=$(echo "$END" | awk -F: '{ print ($1*60)+$2 }')
	DUR=$(( (E_SEC - S_SEC) * 100 ))
	DELAYS+=("$DUR")

	# Add label overlay
	W=$(magick identify -format "%w" "$RAW")
	H=$(magick identify -format "%h" "$RAW")
	PAD=$((H / 20))

	magick "$RAW" \
		-fill "$TEXT_BG" \
		-draw "rectangle 0,$((H - PAD * 2)) $W,$H" \
		-fill "$TEXT_COLOR" \
		-font "$FONT" \
		-pointsize $((H / 28)) \
		-gravity southwest \
		-annotate "+${PAD}+${PAD}" "$LABEL" \
		"$LABELED"

	FRAME_FILES+=("$LABELED")
done < "$SPECS"

if [ ${#FRAME_FILES[@]} -eq 0 ]; then
	echo "Error: no frames found in specs.txt"
	exit 1
fi

echo "Creating GIF (${#FRAME_FILES[@]} frames)..."
magick "${FRAME_FILES[@]}" \
	-delay "${DELAYS[@]}" \
	-loop 0 \
	"$OUTPUT"

echo "Done! GIF saved to: $OUTPUT"
