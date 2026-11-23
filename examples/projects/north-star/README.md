# North star

The palette of Dean's first track: spoken word over Detroit techno, with a
Jersey garage twist (Tony Humphries, Kerri Chandler) and West African drums
that mix machines with recordings. The precedent is Jeff Mills playing a
TR-909 live against Tony Allen's Afrobeat kit on *Tomorrow Comes the
Harvest* (2018). The section "North star" of
[spec/components/benchmarks.md](../../../spec/components/benchmarks.md)
describes eight benchmarks and their sources.

Built so far:

- BM-AFRO-01: the standard bell pattern on a 12-step triplet grid over a 909
  four, with a `flattened` take that squeezes it onto sixteenths, the way
  most Afro house programs it.
- BM-AFRO-02: the uneven long-short-short feel of Malian jembe drumming
  (41:31:28 of a beat, from Polak and London 2014), with an `even` take.

- BM-KEYS-01: one minor ninth shape moved in parallel over a 909 four, the
  last stab of every second bar thrown into a dotted-eighth echo. It asks
  for the `chords` measurement (REQ-BEN-19): every stab's strongest notes
  are its own five.
- BM-BASS-02: the Korg M1 "Organ 2" garage bass over the Jersey shuffle,
  measured for `pitch` (every note within 10 cents) and `mono-low` (the
  chorus leaves the low end mono).

```sh
uv run mph bench render BM-AFRO-01
```

The bell, djembe (its stroke is a parameter: 0 bass, 1 tone, 2 slap) and
dunun are SuperCollider synths: Dean's library has no agogo, shekere or
talking drum, and its djembes are loops. `mph projects fill north-star`
looks for one-shots; on Dean's own catalogue these five voices are all it
finds missing across every example project (2026-11-21). On BM-AFRO-01
Dean preferred the synth-kit shaker.

Both new ones are SuperCollider takes for now: Renoise takes of melodic
benchmarks wait for #30.

Still to build: BM-AFRO-03 (a borrowed conga groove, which needs a recorded
conga loop in the catalogue) and BM-MIX-01 (a layered kick), issue #39.
Left out in this fork, which keeps the north star instrumental (Adam,
2026-11-23): BM-VOX-03 (a sermon in the gaps) and BM-AFRO-04 (talking drum
answers to the voice), issue #41.

Track 1 in this palette, built from these parts, is its own project:
[north-star-track-1-iron-and-skin](../north-star-track-1-iron-and-skin/).
