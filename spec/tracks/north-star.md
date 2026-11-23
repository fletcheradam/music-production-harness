# North star tracks

**Status:** draft (track 1, Iron and Skin, first version 2026-11-23)

Tracks in the north star palette (spec/components/benchmarks.md, section
North star): Detroit techno with a Jersey garage twist and West African
drums played by machines and, where the catalogue has them, recordings.

In this fork the tracks are instrumental and underground: no vocals, no
vocoders and no synthetic voices of any kind (Adam, 2026-11-23). So the
spoken word of the original brief is left out, with the two benchmarks
built on it: BM-VOX-03 (a sermon in the gaps) and BM-AFRO-04 (a talking drum
answering the voice). The parallel stabs, the thrown echoes and the
breakdowns carry the call and response the voice would have led.

Every part is a SuperCollider synth (REQ-BEN-05's fallback, or a synth the
score names), so a fresh install with no catalogue renders the whole track,
and a catalogue swaps the drums for its own hits by role.

## North star track 1: Iron and Skin

The meeting of Jeff Mills' TR-909 and Tony Allen's kit on *Tomorrow Comes
the Harvest* (2018), in the parts the north star benchmarks test: the bell
timeline over the four (BM-AFRO-01), the jembe feel (BM-AFRO-02), the
parallel minor ninth stabs (BM-KEYS-01) and the Jersey organ bass
(BM-BASS-02), with a 303 line for the second peak (BM-BASS-01). C minor, the
chord memory moving C, C, Bb, Ab, one chord a bar. 392 bars at 122 BPM
(12:51, about 13 minutes with the tail), the length roadmap step 5 asks for.

### BM-NST-01: Iron and Skin, the whole track
122 BPM, 16th swing 54%, triplets in the jembe feel (41:31:28), 392 bars.

| Bars | Section | What plays |
|---|---|---|
| 1-16 | DJ intro | kick, closed hats, rim |
| 17-32 | The bell | the bell's seven strokes and the triplet shaker join, with open hats |
| 33-48 | Build | the clap, the dunun and the rolling bass join, the bass's filter shut |
| 49-64 | Groove A | the ride, djembe tones and slaps, and the stabs: the whole groove |
| 65-72 | Two clocks | the machines stop: the African ensemble alone under the strings |
| 73-104 | Groove B | the whole groove again, the bass and stabs opening up |
| 105-120 | Jersey | the organ bass takes over from the bass, with shaker, tones and strings |
| 121-136 | Jersey | the ride, bell, slaps and dunun come back |
| 137-152 | Dub | kick, hats, ride, rim and bass, the stabs and rim deep in the echo |
| 153-168 | Breakdown | the bell, shaker, stabs and strings, with no kick |
| 169-176 | The ensemble | the bell, shaker, djembe and dunun on their own |
| 177-208 | Peak | everything but the organ and the acid, the stabs wide open |
| 209-240 | Acid | a 303 pedal on C takes the bass's place, opening over 32 bars |
| 241-256 | Dub II | kick, hats, ride, rim, the acid closing down and the thrown stabs |
| 257-272 | Jersey II | the organ bass, shaker, djembe, stabs and strings |
| 273-304 | Peak II | the whole kit and the ensemble over the organ bass |
| 305-320 | Breakdown II | bell, tones, dunun and strings |
| 321-352 | Last groove | the Detroit groove with the rolling bass |
| 353-368 | Outro | kick, hats, rim, bell, shaker and the bass closing down |
| 369-384 | Outro | kick, closed hats, rim and bell |
| 385-392 | DJ outro | kick, closed hats, rim |

The stabs play on off-beat sixteenths, and the last stab of every second
bar is a voice of its own (`throw`), sent whole into the dotted-eighth echo.
The kick ducks the bass, the organ bass, the strings and the acid by 18 dB,
released over 380 ms. Measurements: the shared ones, every chord's
strongest notes are its own (REQ-BEN-19), and the low end is mono.

Hear: a Detroit techno track where two clocks run at once. A dry 909 four
opens it, and the iron bell's lopsided seven strokes arrive over it, then
the djembe and dunun, leaning in the long-short-short jembe feel while the
kick stays locked. Parallel minor ninth stabs hang over a rolling bass,
with every fourth bar's last stab thrown into the echo. The Jersey
sections swap the bass for a round, honking organ bass and open up the
strings. The dubs strip back to kick, rim, ride and echoes, the breaks
leave the African ensemble on its own, an acid line takes the second peak,
and the track winds down to kick and hats for the next DJ. No voices at
all.
- **Why:** the north star is a track, not a set of benchmarks (roadmap step
  5): about 13 minutes in this palette. Adam asked for it on 2026-11-23,
  instrumental and underground, before every benchmark it draws on had been
  rated, so it is a first version to listen to and change: the blocks below
  can be rated on their own.
- **Verify:** measure, listen

### BM-NST-02: Iron and Skin, bars 41-80: groove A and the two clocks
122 BPM, 16th swing 54%. Bars 41-80 of BM-NST-01.

Hear: the bell and dunun over the 909 four and the bass, then the djembe
and the stabs come in and the groove locks. At bar 25 of the block the
machines stop and the African ensemble plays on its own under the strings,
leaning in the jembe feel, before the kick drops back in.
- **Why:** the heart of the palette: do the bell and the leaning ensemble
  sit with a locked 909, and does the ensemble hold up on its own?
- **Verify:** measure, listen

### BM-NST-03: Iron and Skin, bars 97-136: into Jersey
122 BPM, 16th swing 54%. Bars 97-136 of BM-NST-01.

Hear: the full Detroit groove, then at bar 9 of the block the rolling bass
gives way to the organ bass: round, woody and honking, with the strings
opening above it and the bell and slaps coming back halfway through.
- **Why:** the Jersey twist is the brief's second colour. The hand-over
  from the Detroit bass to the organ bass has to lift the track, not stall
  it.
- **Verify:** measure, listen

### BM-NST-04: Iron and Skin, bars 201-248: acid and dub
122 BPM, 16th swing 54%. Bars 201-248 of BM-NST-01.

Hear: the peak with the stabs wide open, then an acid line takes over from
the bass, squelching and opening over 32 bars while the bell keeps its
seven strokes above. It drops into a dub of kick, rim, ride, the acid
closing down and the thrown stabs echoing.
- **Why:** 13 minutes needs a second idea after the first peak. A 303 is
  Detroit's own, and it tests whether the acid sits with the triplet
  drums.
- **Verify:** measure, listen
