# Elsewhere

An original track, made entirely from SuperCollider synths. It takes its feel
from Fred again.. / Anderson .Paak / CHIKA's "places to be" (2024): a crisp,
live-sounding breakbeat, a buzzy bass with a sliding sub, and vocal-style
chops thrown into a delay whose speed keeps changing. Nothing from that
record is used. The chords, chop melody, bass line and every sound are new.

Then it does something of its own: the tempo climbs from 124 to 174 BPM over
16 bars, and the track turns into drum and bass.

| Bars | Section | BPM | What happens |
|---|---|---|---|
| 1-8 | Intro | 124 | Electric piano chords open up from a low-pass; first chops; hats come in |
| 9-24 | Groove A | 124 | Swung breakbeat, buzzy bass with slides, chops from bar 17 |
| 25-32 | Groove B | 124 | Full chop phrase in the delay |
| 33-48 | The climb | 124 to 174 | Tempo rises every beat; bass filter opens; snare fills get denser; the delay speeds up with the tempo; a riser |
| 49-80 | Drop 1 | 174 | Two-step DnB break, reese bass and sub, pad chords, impact on the one |
| 81-88 | Breakdown | 174 | Pads and chops in a long, lurching delay; riser |
| 89-104 | Drop 2 | 174 | Everything, plus a ride and extra ghost snares |
| 105-112 | Outro | 174 | Drums and bass drop out, the pad rings out |

About 3 minutes. Key: F minor. Chords: Fm9, Dbmaj9, Abmaj7, Eb/G, one per bar
in the groove and one per two bars in the DnB, so the harmony keeps a similar
pace in seconds as the tempo rises.

## How it's built

- **Tempo ramp.** The score is written in beats. `secAt` turns a beat into
  seconds by integrating the tempo: steady sections are linear, and the climb
  is linear in BPM per beat, so its time is a logarithm. Every note, fill and
  delay change goes through it, so everything stays locked while the tempo
  moves.
- **Sidechain.** Each kick writes its envelope to a private audio bus; the
  bass, keys and pads read it and duck under the kick.
- **The delay.** A ping-pong delay reads its time from a control bus through a
  `Lag`, so changing the time bends the repeats in pitch like a tape speeding
  up. In the climb it follows the tempo; in the breakdown it lurches between
  speeds.
- **Chops.** A breathy buzz through three formant band-passes, with a pitch
  scoop at the start, cycling through five vowels.
- **Master.** Glue compression, a soft clip and a limiter at -1 dBFS.
- Humanising is seeded (`thisThread.randSeed = 2024`), so every render is the
  same.

Render it with the steps in [../../README.md](../../README.md).
