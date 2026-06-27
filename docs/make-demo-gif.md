# make-demo-gif.sh

Create a demo GIF from a screen recording for the README.

## Requirements

```bash
brew install ffmpeg imagemagick gifsicle
```

## Usage

```bash
./scripts/make-demo-gif.sh <directory> [fps] [width]
```

## Directory contents

Each directory must contain:

| File | Description |
|------|-------------|
| `video.mov` | Screen recording (QuickTime or similar) |
| `specs.txt` | One clip per line: `start\|end\|Description` |

## specs.txt format

```
00:05|00:09|Code completion
00:12|00:16|Hover documentation
00:20|00:24|Go to definition
00:28|00:32|Diagnostics
00:36|00:40|Status line
00:44|00:48|Formatter
00:52|00:56|Debugging
01:00|01:04|Outline view
```

Each line creates an animated clip showing that segment with an overlay label.

## Defaults

| Parameter | Default | Description |
|-----------|---------|-------------|
| fps | 12 | frames per second per clip |
| width | 640 | max width in pixels |

## Examples

```bash
# Defaults (12fps, 640px)
./scripts/make-demo-gif.sh ~/Desktop/capture

# Custom
./scripts/make-demo-gif.sh ~/Desktop/capture 15 800

# Lower quality for smaller file
./scripts/make-demo-gif.sh ~/Desktop/capture 8 480
```

## Output

The script generates `demo.gif` in the same directory, optimized with ImageMagick and gifsicle (if available).

## Workflow

1. Record a screen capture with QuickTime Player
2. Move it to a directory as `video.mov`
3. Write `specs.txt` with timestamps and descriptions
4. Run the script
5. Adjust timestamps in `specs.txt` and re-run until satisfied — no need to re-record
