# SuperCollider

Tracks written directly in SuperCollider, outside the benchmark harness. Each
one is a single `.scd` file that builds its own synths and score and renders
offline (non-real-time), so it needs no sound card and renders the same every
time. Audio never goes in git (REQ-ENG-10): renders land next to the file and
are ignored.

| Track | What it is |
|---|---|
| [tracks/elsewhere](tracks/elsewhere/) | A swung 124 BPM breakbeat groove that speeds up, bar by bar, into 174 BPM drum and bass |

## Rendering

macOS (SuperCollider.app):

```sh
/Applications/SuperCollider.app/Contents/MacOS/sclang supercollider/tracks/elsewhere/elsewhere.scd
```

Linux (`apt install supercollider-language supercollider-server`), headless:

```sh
QT_QPA_PLATFORM=offscreen QTWEBENGINE_CHROMIUM_FLAGS=--no-sandbox \
  sclang supercollider/tracks/elsewhere/elsewhere.scd
```

`QT_QPA_PLATFORM=offscreen` lets sclang start with no display, and the
Chromium flag is only needed when running as root (a cloud container). Set
`ELSEWHERE_OUT=/path/to/file.wav` to render somewhere else.

The harness's own SuperCollider renders (`uv run mph bench render`) use the
same two variables on Linux.
