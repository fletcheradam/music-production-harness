# North star track 1: Iron and Skin

A 13-minute instrumental track in the north star palette
([spec/tracks/north-star.md](../../../spec/tracks/north-star.md)): Detroit
techno with a Jersey garage twist and West African drums, after Jeff Mills'
909 meeting Tony Allen's kit. 392 bars at 122 BPM in C minor.

No voices of any kind: no vocals, vocoders or synthetic voices (Adam,
2026-11-23). The stabs, the thrown echoes and the breaks do the call and
response.

What plays, from the north star benchmarks:

- a 909 kit, straight and locked, with a push every fourth bar;
- the iron bell's seven strokes and a triplet shaker (BM-AFRO-01);
- djembe tones and slaps and a dunun in the jembe feel, 41:31:28 of a beat
  (BM-AFRO-02);
- parallel minor ninth stabs moving C, C, Bb, Ab, with a throw into the
  dotted-eighth echo every second bar (BM-KEYS-01);
- a rolling Detroit bass, and an M1-style organ bass in the Jersey sections
  (BM-BASS-02);
- strings in the breaks, and a 303 pedal for the acid section (BM-BASS-01).

Every part is a SuperCollider synth, so it renders on a fresh install with
no samples. With a catalogue, the drums are picked from it by role.

```sh
uv run mph bench render BM-NST-01 --variant supercollider   # the whole track
uv run mph bench render BM-NST-02 BM-NST-03 BM-NST-04       # the blocks to rate first
```

Examples are off by default in this fork, so turn this project on in your
config first: `[projects] examples = ["north-star", "north-star-track-1-iron-and-skin"]`.

What Adam thought: not rated yet (first version, 2026-11-23).
