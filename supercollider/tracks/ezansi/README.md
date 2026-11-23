# Ezansi

An original amapiano / afrotech track, made entirely from SuperCollider synths.
Ezansi is isiZulu for "down south". It starts as amapiano, turns into afrotech
in the middle, then puts the two together. No samples are used, and the
chords, log drum lines, bell motifs and every sound are new.

113 BPM, D minor: D dorian in the amapiano parts, D phrygian (with its flat
second, Eb) in the afrotech part. Chords, two bars each: Dm9, G13, Bbmaj9,
A9sus4. About 3:30.

| Bars | Section | What happens |
|---|---|---|
| 1-8 | Intro | Shakers, electric piano chords opening up from a low-pass, rims |
| 9-24 | Foundation | Soft four-on-the-floor kick, dry clap on 2 and 4, open hats, congas from bar 17; the log drum walks in on the last beat |
| 25-40 | Log drum | The log drum takes over the low end; beat 3's kick drops every other bar so it carries the pulse; a bell call every 4 bars |
| 41-48 | Breakdown | No kick: pads and a wordless choir carry the chords, the log drum slides down from the octave, hand drums creep in under a riser |
| 49-72 | Afrotech | The chords drop away. A dark drone (D, Eb, D, C...), a locked conga, djembe and woodblock loop, a chant, a hypnotic log line on D with an Eb pop, and a bell arpeggio that places a note every three 16ths so it drifts against the bar |
| 73-88 | Return | The amapiano chords and log drum come back over the afrotech drums, with a log drum fill every 8 bars |
| 89-96 | Outro | Drums thin out to keys and shakers; the last chord rings |

## What it draws on

Researched before writing (Splice's interview with Kooldrink, Music Production
Wiki on the log drum, BeatsToRapOn's amapiano guide, Wikipedia and Mixmag on
afrotech):

- **Amapiano** (Kabza De Small, DJ Maphorisa, MFR Souls, Kooldrink; the log
  drum is credited to MDU aka TRP): 108-115 BPM, a soft house kick, swung 16th
  shakers with accents and gaps, dry claps, rims as answers, jazzy 7th/9th/11th
  chords on electric piano, and the log drum as a tuned, gliding voice that is
  bass and kick at once, played in two-bar call-and-response phrases with gaps.
- **Afrotech** (Black Coffee, Culoe De Song, Shimza, Enoo Napa): afro house
  with a techno influence at a lower tempo, darker, with long menacing notes,
  constant entrancing hand-drum loops (congas, djembe), bells and short
  recurring synth patterns, and incantation-like vocals.

## How it's built

- **Log drum.** FM with the modulator an octave up and its index on a fast
  envelope, so the knock is only at the attack; a quick pitch blip; a glide
  from the previous note; a sine sub under it with the same envelope;
  saturation so it speaks on small speakers. Each chord gives five tones
  (root, fifth, octave, seventh, a colour note) and the phrases pick from them,
  so the same two-bar rhythm follows the chords.
- **Sidechain.** Each kick writes its envelope to a private audio bus; the
  keys, pads, drone and (lightly) the log drum duck under it. They read it with
  `InFeedback`, so node order doesn't matter.
- **Hand drums.** One tuned-membrane synth (a sine with a small pitch drop, a
  second mode and a noise slap) plays conga tones, slaps and the djembe bass.
- **Master.** The low end is made mono below about 120 Hz, then glue
  compression, a soft clip and a limiter at about -1.6 dBFS. Around -13 LUFS.
- Humanising is seeded (`thisThread.randSeed = 113`), so every render is the
  same.

`EZANSI_SOLO=ez_log,ez_kick` renders only the named synths (effects and master
still run), which helps when balancing parts. `EZANSI_OUT` sets the output
path. Render it with the steps in [../../README.md](../../README.md).
