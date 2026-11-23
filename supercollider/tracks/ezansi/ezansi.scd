// "Ezansi": an original amapiano / afrotech track, written in SuperCollider.
//
// Ezansi is isiZulu for "down south". The track starts as amapiano (soft
// four-on-the-floor kick, swung 16th shakers, dry claps and rims, jazzy
// electric piano chords and a gliding log drum carrying the low end), turns
// into afrotech in the middle (the chords drop away for a dark drone, congas
// and djembe lock into a hypnotic loop, a bell arpeggio runs in threes against
// the fours, the log drum leans on a phrygian flat second), then brings the
// amapiano chords back over the afrotech drums.
//
// Every sound is synthesised here. No samples are used, and the chords,
// log drum lines and melodies are new.
//
//   bars  1-8    intro        shakers, filtered keys opening up, rims
//   bars  9-24   foundation   kick, clap, shakers, keys; congas from bar 17
//   bars 25-40   log drum     the log drum enters and carries the bass
//   bars 41-48   breakdown    no kick: pads, choir, sparse log slides, riser
//   bars 49-72   afrotech     drone, congas and djembe, bell arp in threes, choir
//   bars 73-88   return       amapiano chords and log drum over the afrotech drums
//   bars 89-96   outro        thins out to keys and shakers; the last chord rings
//
// 113 BPM, D minor (D dorian in the amapiano parts, D phrygian in the afrotech
// part). Chords, two bars each: Dm9, G13, Bbmaj9, A9sus4.
//
// Render (no audio device needed; writes a 48 kHz / 24-bit WAV next to this
// file, or to the path given in $EZANSI_OUT):
//   QT_QPA_PLATFORM=offscreen sclang ezansi.scd
//
// Renders are deterministic: the random humanising is seeded.

(
var sr = 48000, bpm = 113;
var here = thisProcess.nowExecutingPath.dirname;
var outPath = "EZANSI_OUT".getenv ?? (here +/+ "ezansi.wav");
var solo = "EZANSI_SOLO".getenv;   // e.g. "ez_log,ez_kick": render only these
var score = List.new;
var defs = List.new;
var sections, totalBars, secAt, bar2beat, add, addDur, beatsPerBar = 4;
var srcG = 1000, fxG = 1001, masterG = 1002;
var mBus = 16, revBus = 18, dlyBus = 20, duckBus = 22;
var chords, logA, logB, logTech, keysRhythm, bellMotif, bellArp, rng, endBeat, endSec;

thisThread.randSeed = 113;

// ---------------------------------------------------------------- synths

// Kick: a soft, rounded house kick that stays out of the log drum's way.
// Writes its envelope to duckBus so the keys, pads and drone breathe around it.
defs.add(SynthDef(\ez_kick, { |amp = 1, decay = 0.3|
    var env = EnvGen.ar(Env.perc(0.002, decay, 1, -6), doneAction: 2);
    var penv = EnvGen.ar(Env([3.2, 1.3, 1], [0.025, 0.08], [-4, -2]));
    var body = SinOsc.ar(54 * penv, 0.5pi) * env;
    var click = LPF.ar(HPF.ar(WhiteNoise.ar, 1500), 6000) * EnvGen.ar(Env.perc(0, 0.004)) * 0.2;
    var sig = (body * 1.2 + click).tanh * amp * 0.7;
    Out.ar(duckBus, EnvGen.ar(Env.perc(0.002, 0.22, 1, -3)) * amp.min(1));
    Out.ar(mBus, sig ! 2);
}));

// Log drum: a low FM voice. The modulator sits an octave up with its index
// on a fast envelope, so the FM "knock" is only at the attack; a quick pitch
// blip and a glide from the previous note give the walk; a sine sub with the
// same envelope sits under it; saturation lets it speak on small speakers.
defs.add(SynthDef(\ez_log, { |freq = 73.4, from = 73.4, slide = 0.05, amp = 1, dec = 0.3, drive = 2.2, pan = 0|
    var glide = XLine.kr(from, freq, slide.max(0.001));
    var f = glide * EnvGen.kr(Env([1.5, 1], [0.03], -4));
    var idx = EnvGen.ar(Env([3.2, 0.5, 0.2], [0.05, dec], [-4, -2]));
    var mod = SinOsc.ar(f * 2) * f * idx;
    var car = SinOsc.ar(f + mod);
    var env = EnvGen.ar(Env([0, 1, 0.55, 0], [0.002, 0.07, dec], [0, -2, -4]), doneAction: 2);
    var knock = BPF.ar(WhiteNoise.ar, 1600, 0.4) * EnvGen.ar(Env.perc(0, 0.012)) * 0.35;
    var tine = SinOsc.ar(f * 4.02) * EnvGen.ar(Env.perc(0.001, 0.05)) * 0.18;
    var sub = SinOsc.ar(glide) * 0.75;
    var duck = 1 - (InFeedback.ar(duckBus) * 0.35);
    var sig = (((car + knock + tine) * drive).tanh * 0.55 + sub) * env;
    sig = LPF.ar(sig, 3200) * amp * 4.5 * duck;
    Out.ar(mBus, Pan2.ar(sig, pan));
}));

// Shaker: band-passed noise with a slightly soft attack.
defs.add(SynthDef(\ez_shaker, { |amp = 1, decay = 0.055, pan = 0.25|
    var env = EnvGen.ar(Env([0, 1, 0], [0.006, decay], [2, -5]), doneAction: 2);
    var sig = (BPF.ar(WhiteNoise.ar, 7200, 0.7) + HPF.ar(WhiteNoise.ar, 9500, 0.3)) * env * amp * 2.6;
    Out.ar(mBus, Pan2.ar(sig, pan));
}));

// Open hat: metallic partials and noise, a little longer.
defs.add(SynthDef(\ez_ohat, { |amp = 1, decay = 0.16, pan = -0.2|
    var env = EnvGen.ar(Env.perc(0.002, decay, 1, -4), doneAction: 2);
    var metal = Pulse.ar([3355, 4712, 5918, 7301], 0.5).sum * 0.15;
    var sig = HPF.ar(WhiteNoise.ar * 0.6 + metal, 8000) * env * amp * 2.0;
    Out.ar(mBus, Pan2.ar(sig, pan));
}));

// Clap: three quick noise bursts and a short tail, kept dry.
defs.add(SynthDef(\ez_clap, { |amp = 1, pan = 0|
    var env = EnvGen.ar(Env([0, 1, 0.15, 1, 0.15, 1, 0], [0.001, 0.009, 0.001, 0.009, 0.001, 0.14], [0, -4, 0, -4, 0, -5]), doneAction: 2);
    var sig = BPF.ar(WhiteNoise.ar, 1350, 0.7) * 2 + HPF.ar(WhiteNoise.ar, 5000, 0.3);
    sig = sig * env * amp * 4.0;
    Out.ar(mBus, Pan2.ar(sig, pan));
    Out.ar(revBus, Pan2.ar(sig * 0.08, pan));
}));

// Rim: a short tuned click; some go into the delay as answers.
defs.add(SynthDef(\ez_rim, { |amp = 1, pan = 0.3, send = 0|
    var env = EnvGen.ar(Env.perc(0.0005, 0.035, 1, -6), doneAction: 2);
    var sig = (SinOsc.ar(1720) * 0.6 + BPF.ar(WhiteNoise.ar, 2600, 0.3) * 1.5 + SinOsc.ar(470) * 0.3) * env * amp * 3.5;
    Out.ar(mBus, Pan2.ar(sig, pan));
    Out.ar(dlyBus, Pan2.ar(sig * send, pan));
}));

// Hand drums: conga (open tone or slap) and a djembe bass. A tuned membrane:
// sine with a small pitch drop, a second mode, and a noise slap.
defs.add(SynthDef(\ez_hand, { |freq = 220, amp = 1, decay = 0.2, slap = 0, pan = 0|
    var env = EnvGen.ar(Env.perc(0.001, decay, 1, -5), doneAction: 2);
    var f = freq * EnvGen.kr(Env([1.25, 1], [0.025], -3));
    var tone = SinOsc.ar(f) + (SinOsc.ar(f * 1.59) * 0.25 * EnvGen.ar(Env.perc(0, decay * 0.4)));
    var hit = BPF.ar(WhiteNoise.ar, 1800 + (slap * 1500), 0.6) * EnvGen.ar(Env.perc(0, 0.015 + (slap * 0.03))) * (0.3 + (slap * 1.2));
    var sig = (tone * env + hit).tanh * amp * 0.5;
    Out.ar(mBus, Pan2.ar(sig, pan));
    Out.ar(revBus, Pan2.ar(sig * 0.12, pan));
}));

// Woodblock.
defs.add(SynthDef(\ez_wood, { |amp = 1, freq = 1050, pan = -0.4|
    var env = EnvGen.ar(Env.perc(0.0005, 0.06, 1, -6), doneAction: 2);
    var sig = (Ringz.ar(Impulse.ar(0) * 0.5, freq, 0.05) + Ringz.ar(Impulse.ar(0) * 0.2, freq * 2.7, 0.03)) * env * amp;
    Out.ar(mBus, Pan2.ar(sig * 2.4, pan));
    Out.ar(revBus, Pan2.ar(sig * 0.4, pan));
}));

// Bell: inharmonic FM (ratio 3.5), for the call motif and the afrotech arp.
defs.add(SynthDef(\ez_bell, { |freq = 587, amp = 0.2, decay = 1.2, pan = 0, send = 0.3, bright = 1|
    var env = EnvGen.ar(Env.perc(0.001, decay, 1, -5), doneAction: 2);
    var idx = EnvGen.ar(Env([2.2 * bright, 0.3], [decay * 0.5], -4));
    var mod = SinOsc.ar(freq * 3.5) * freq * idx;
    var sig = (SinOsc.ar(freq + mod) + (SinOsc.ar(freq * 2.001) * 0.15)) * env * amp;
    Out.ar(mBus, Pan2.ar(sig, pan));
    Out.ar(dlyBus, Pan2.ar(sig * send, pan));
    Out.ar(revBus, Pan2.ar(sig * 0.25, pan));
}));

// Keys: an electric piano, FM at ratio 1 with a tine at ratio 14, tremolo
// and a low-pass that the intro opens.
defs.add(SynthDef(\ez_keys, { |freq = 440, amp = 0.2, sus = 0.3, cut = 4000, pan = 0|
    var env = EnvGen.ar(Env([0, 1, 0.5, 0], [0.003, sus, 0.35], [-2, -2, -4]), doneAction: 2);
    var mod = SinOsc.ar(freq) * freq * 1.4 * EnvGen.ar(Env.perc(0.001, 0.6, 1, -4));
    var tine = SinOsc.ar(freq * 14) * EnvGen.ar(Env.perc(0.0005, 0.03)) * 0.12;
    var car = SinOsc.ar(freq + mod) + (SinOsc.ar(freq * 0.998) * 0.35) + tine;
    var trem = SinOsc.kr(5.1, [0, pi]).range(0.75, 1);
    var duck = 1 - (InFeedback.ar(duckBus) * 0.4);
    var sig = LPF.ar(car, cut) * env * amp * duck;
    sig = Pan2.ar(sig, pan) * trem;
    Out.ar(mBus, sig);
    Out.ar(revBus, sig * 0.25);
}));

// Pad: warm detuned saws, slow attack, for the breakdown.
defs.add(SynthDef(\ez_pad, { |freq = 220, amp = 0.1, sus = 2, cut = 1800, atk = 0.6|
    var env = EnvGen.ar(Env([0, 1, 1, 0], [atk, sus, 1.5], [2, 0, -3]), doneAction: 2);
    var osc = Saw.ar(freq * [0.996, 1.004]) * 0.5;
    var sig = LPF.ar(osc, cut * LFTri.kr(0.11).range(0.75, 1.25)) * env * amp;
    var duck = 1 - (InFeedback.ar(duckBus) * 0.6);
    sig = sig * duck;
    Out.ar(mBus, sig);
    Out.ar(revBus, sig * 0.5);
}));

// Drone: the afrotech menace. Detuned saws and a pulse an octave down,
// through a resonant low-pass that slowly sweeps, saturated.
defs.add(SynthDef(\ez_drone, { |freq = 73.4, from = 73.4, amp = 0.2, sus = 8, cut = 400, cutTo = 1600, atk = 1.5|
    var f = XLine.kr(from, freq, 0.6);
    var env = EnvGen.ar(Env([0, 1, 1, 0], [atk, sus, 2], [2, 0, -3]), doneAction: 2);
    var osc = Saw.ar(f * [1, 1.007, 0.993]).sum * 0.35 + Pulse.ar(f * 0.5, LFTri.kr(0.2).range(0.2, 0.5), 0.4);
    var c = XLine.kr(cut, cutTo, sus + atk) * LFTri.kr(0.23).range(0.8, 1.2);
    var sig = (RLPF.ar(osc, c, 0.3) * 1.8).tanh;
    var duck = 1 - (InFeedback.ar(duckBus) * 0.75);
    sig = sig * env * amp * duck;
    Out.ar(mBus, [DelayC.ar(sig, 0.02, 0.011), sig]);
    Out.ar(revBus, sig * 0.2 ! 2);
}));

// Choir: a sung "oo"/"ah" made from a buzzy source and three formant
// band-passes, with vibrato and a slow swell. Wordless, chant-like.
defs.add(SynthDef(\ez_choir, { |freq = 293.7, amp = 0.1, sus = 2, atk = 0.5, vowel = 0, pan = 0|
    var env = EnvGen.ar(Env([0, 1, 1, 0], [atk, sus, 0.9], [2, 0, -3]), doneAction: 2);
    var f = freq * (1 + SinOsc.kr(5.2 + Rand(-0.4, 0.4), Rand(0, 6), 0.007));
    var src = Saw.ar(f * [1, 1.003, 0.997]).sum * 0.4 + PinkNoise.ar(0.02);
    var fm = [[350, 750, 450], [700, 1150, 850], [2500, 2800, 2600]].collect { |a| Select.kr(vowel, a) };
    var sig = BPF.ar(src, fm[0], 0.1) + (BPF.ar(src, fm[1], 0.09) * 0.55) + (BPF.ar(src, fm[2], 0.07) * 0.25);
    sig = HPF.ar(sig * 4, 150) * env * amp;
    Out.ar(mBus, Pan2.ar(sig, pan));
    Out.ar(revBus, Pan2.ar(sig * 0.6, pan));
}));

// Riser and impact.
defs.add(SynthDef(\ez_riser, { |dur = 8, amp = 0.2|
    var env = EnvGen.ar(Env([0, 1, 0], [dur, 0.02], [4, -4]), doneAction: 2);
    var cut = EnvGen.kr(Env([250, 7000], [dur], \exp));
    var sig = RLPF.ar(WhiteNoise.ar ! 2, cut, 0.35) * env * amp;
    Out.ar(mBus, sig);
    Out.ar(revBus, sig * 0.4);
}));
defs.add(SynthDef(\ez_impact, { |amp = 0.5|
    var env = EnvGen.ar(Env.perc(0.001, 2.2, 1, -6), doneAction: 2);
    var sig = (SinOsc.ar(EnvGen.ar(Env([110, 36], [0.35], \exp))) + (LPF.ar(WhiteNoise.ar, 2000) * 0.25)) * env * amp;
    Out.ar(mBus, sig ! 2);
    Out.ar(revBus, sig * 0.5 ! 2);
}));

// Effects: a dotted-eighth ping-pong delay and a room-to-hall reverb.
defs.add(SynthDef(\ez_delay, { |time = 0.4, fb = 0.45|
    var in = In.ar(dlyBus, 2);
    var loop = LocalIn.ar(2);
    var dl = DelayC.ar(in + (loop.reverse * fb), 1.0, time);
    var shaped = LPF.ar(HPF.ar(dl, 400), 4500);
    LocalOut.ar(shaped);
    Out.ar(mBus, shaped * 0.6);
    Out.ar(revBus, shaped * 0.2);
}));
defs.add(SynthDef(\ez_verb, {
    var in = In.ar(revBus, 2);
    var sig = FreeVerb2.ar(in[0], in[1], 1, 0.82, 0.5);
    Out.ar(mBus, HPF.ar(sig, 220) * 0.85);
}));

// Master: the low end stays mono below ~120 Hz, then glue compression,
// a soft clip and a limiter at -1 dBFS.
defs.add(SynthDef(\ez_master, { |gain = 1.7|
    var in = In.ar(mBus, 2) * gain;
    var low = LPF.ar(LPF.ar(in, 120), 120);
    var mono = low.sum * 0.5;
    var sig = (in - low) + [mono, mono];
    var comp = Compander.ar(sig, sig, 0.45, 1, 0.55, 0.01, 0.15);
    sig = Limiter.ar(LeakDC.ar((comp * 1.2).tanh), 0.83, 0.01);
    Out.ar(0, sig);
}));

// ---------------------------------------------------------------- timeline

// [name, bars]
sections = [
    [\intro,  8],
    [\found,  16],
    [\logA,   16],
    [\brk,    8],
    [\tech,   24],
    [\ret,    16],
    [\outro,  8],
];
totalBars = sections.collect(_[1]).sum;
endBeat = totalBars * beatsPerBar;

secAt = { |b| b * 60 / bpm };
bar2beat = { |bar| (bar - 1) * beatsPerBar };

add = { |beat, def, args, group = 1000|
    if (solo.isNil or: { solo.split($,).collect(_.asSymbol).includes(def) }) { score.add([secAt.(beat), [\s_new, def, -1, 0, group] ++ args]) };
};
addDur = { |beat, beats, def, args|
    var sus = (secAt.(beat + beats) - secAt.(beat)).max(0.02);
    add.(beat, def, [\sus, sus] ++ args);
};

// ---------------------------------------------------------------- material

// Two bars per chord: Dm9, G13, Bbmaj9, A9sus4.
// [keys voicing, log drum tones: root, fifth, octave, seventh, colour]
chords = [
    [[53, 57, 60, 64], [38, 45, 50, 48, 41]],   // Dm9:    F A C E   | D A D C F
    [[53, 57, 59, 64], [43, 50, 55, 41, 47]],   // G13:    F A B E   | G D G F B
    [[53, 57, 60, 62], [34, 41, 46, 45, 38]],   // Bbmaj9: F A C D   | Bb F Bb A D
    [[55, 59, 62, 64], [33, 40, 45, 43, 38]],   // A9sus4: G B D E   | A E A G D
];

// Log drum phrases, one bar each, 16th steps: [step, tone index, length].
// Bar one states the idea, bar two answers it.
logA = [[0, 0, 3], [3, 0, 2], [6, 2, 2], [10, 1, 3], [14, 3, 2]];
logB = [[2, 0, 2], [4, 3, 2], [8, 0, 4], [12, 4, 1], [13, 1, 1], [14, 2, 2]];

// The afrotech log line: hypnotic, on D, with an octave pop and the flat
// second (Eb) for menace. [step, midi, length]
logTech = [[0, 38, 3], [3, 38, 2], [6, 50, 1], [7, 51, 2], [10, 38, 3], [13, 45, 1], [14, 48, 2]];

// Electric piano rhythm, two bars of 16ths: [step, length].
keysRhythm = [
    [[0, 3], [3, 3], [7, 2], [10, 5]],
    [[2, 2], [6, 3], [10, 2], [12, 4]],
];

// Bell call motif over two bars (D minor pentatonic), and the afrotech arp:
// five notes placed every three 16ths, so it drifts against the bar.
bellMotif = [[0, 74], [3, 77], [6, 76], [10, 72], [12, 74], [22, 69], [24, 72], [27, 74]];
bellArp = [62, 69, 65, 63, 69];

// ---------------------------------------------------------------- arrangement

rng = { |lo, hi| lo + 1.0.rand * (hi - lo) };

score.add([0.0, [\g_new, srcG, 0, 0]]);
score.add([0.0, [\g_new, fxG, 3, srcG]]);
score.add([0.0, [\g_new, masterG, 3, fxG]]);
score.add([0.0, [\s_new, \ez_delay, 2000, 0, fxG, \time, 60 / bpm * 0.75, \fb, 0.42]]);
score.add([0.0, [\s_new, \ez_verb, 2001, 1, fxG]]);
score.add([0.0, [\s_new, \ez_master, 2002, 0, masterG]]);

{
    var startBar = 1, techBar = 0, arpStep = 0;
    sections.do { |s|
        var name = s[0], bars = s[1];
        bars.do { |i|
            var bar = startBar + i;
            var b0 = bar2beat.(bar);
            var last = i == (bars - 1);
            var progress = i / bars;
            var chordIdx = ((bar - 1) div: 2) % 4;
            var chord = chords[chordIdx];
            var second = (bar - 1).odd;              // second bar of a chord
            var swing = 0.045;
            var st = { |step| b0 + (step * 0.25) + (if (step.odd) { swing } { 0 }) };
            var amapiano = [\found, \logA, \ret].includes(name);
            var tech = name == \tech;
            var kickOn = amapiano or: { tech } or: { name == \outro and: { i < 4 } };

            // ---- kick: four on the floor; in the log drum sections beat 3
            // drops out every other bar so the log drum carries the pulse
            if (kickOn) {
                4.do { |q|
                    var skip = (name == \logA or: { name == \ret }) and: { q == 2 and: { second } };
                    if (skip.not) { add.(st.(q * 4), \ez_kick, [\amp, if (tech) { 1 } { 0.85 }]) };
                };
            };

            // ---- shakers: swung 16ths, accents on the off-beat 8ths,
            // occasional missing hits, a pattern change every 4 bars
            if (name != \brk or: { i < 6 }) {
                var level = case
                    { name == \intro } { 0.35 + (progress * 0.4) }
                    { name == \outro } { 0.75 - (progress * 0.5) }
                    { true } { 0.8 };
                16.do { |k|
                    var accent = [2, 6, 10, 14].includes(k);
                    var drop = (bar % 4 == 3) and: { [5, 13].includes(k) };
                    if (drop.not) {
                        add.(st.(k), \ez_shaker, [\amp, level * (if (accent) { rng.(0.85, 1) } { rng.(0.35, 0.55) }),
                            \decay, if (accent) { 0.08 } { 0.045 }, \pan, rng.(0.1, 0.35)]);
                    };
                };
            };

            // ---- open hats on the off-beats
            if (amapiano or: { tech and: { i >= 8 } }) {
                [2, 6, 10, 14].do { |k| add.(st.(k), \ez_ohat, [\amp, rng.(0.5, 0.65)]) };
            };

            // ---- clap on 2 and 4, dry
            if (kickOn) {
                [4, 12].do { |k| add.(st.(k), \ez_clap, [\amp, rng.(0.8, 0.9)]) };
            };

            // ---- rims: call and response, some thrown into the delay
            if ((name == \intro and: { i >= 4 }) or: { amapiano } or: { tech }) {
                var steps = if (second) { [3, 7, 9, 14] } { [3, 6, 11, 14] };
                steps.do { |k, j|
                    add.(st.(k), \ez_rim, [\amp, rng.(0.55, 0.75), \pan, if (j.odd) { 0.35 } { -0.25 },
                        \send, if (k == 14 and: { second }) { 0.6 } { 0 }]);
                };
            };

            // ---- hand drums. Amapiano: a light conga answer. Afrotech: a
            // locked conga / djembe loop and a woodblock.
            if ((name == \found and: { i >= 8 }) or: { name == \logA }) {
                [[7, 330, 0], [11, 247, 0], [15, 330, 1]].do { |h|
                    add.(st.(h[0]), \ez_hand, [\freq, h[1], \slap, h[2], \amp, rng.(1.2, 1.6), \pan, 0.4]);
                };
            };
            if (tech or: { name == \ret }) {
                var lvl = if (tech) { 0.75 } { 0.55 };
                // high conga
                [2, 5, 7, 10, 13, 15].do { |k, j|
                    add.(st.(k), \ez_hand, [\freq, 340, \slap, (j % 3 == 1).asInteger, \amp, lvl * rng.(0.6, 0.85), \pan, 0.45]);
                };
                // low conga
                [3, 11, 14].do { |k| add.(st.(k), \ez_hand, [\freq, 226, \amp, lvl * rng.(0.7, 0.9), \decay, 0.28, \pan, -0.35]) };
                // djembe bass and slap
                add.(st.(6), \ez_hand, [\freq, 96, \amp, lvl * 0.9, \decay, 0.35, \pan, -0.1]);
                if (second) { add.(st.(9), \ez_hand, [\freq, 140, \slap, 1, \amp, lvl * 0.7, \decay, 0.12, \pan, 0.1]) };
                // woodblock, a 3-3-2 figure
                [0, 3, 6, 8, 11, 14].do { |k| add.(st.(k), \ez_wood, [\amp, lvl * rng.(0.35, 0.5)]) };
            };
            if (name == \brk and: { i >= 4 }) {
                // the hand drums creep in under the riser
                ((i - 3) * 3).do { |k| add.(b0 + (k * 4 / ((i - 3) * 3)), \ez_hand, [\freq, 300, \amp, 0.2 + (k * 0.03), \pan, rng.(-0.4, 0.4)]) };
            };

            // ---- log drum
            if (name == \logA or: { name == \ret }) {
                var phrase = if (second) { logB } { logA };
                // in the return, the very last bar of each 8 gets a fill
                if (name == \ret and: { bar % 8 == 0 }) {
                    phrase = [[0, 0, 2], [2, 2, 2], [4, 1, 2], [6, 3, 2], [8, 0, 2], [10, 4, 1], [11, 1, 1], [12, 2, 1], [13, 3, 1], [14, 0, 2]];
                };
                phrase.do { |p, j|
                    var note = chord[1][p[1]];
                    var prevNote = if (j == 0) { note } { chord[1][phrase[j - 1][1]] };
                    var dec = (secAt.(p[2] * 0.25) * 0.9).clip(0.08, 0.45);
                    add.(st.(p[0]), \ez_log, [\freq, note.midicps, \from, prevNote.midicps,
                        \slide, if (j == 0) { 0.001 } { 0.045 }, \dec, dec, \amp, rng.(0.8, 0.95)]);
                };
            };
            if (name == \found and: { last }) {
                // a teaser: the log drum walks in on the last beat
                [[12, 33], [14, 38]].do { |p| add.(st.(p[0]), \ez_log, [\freq, p[1].midicps, \from, (p[1] - 5).midicps, \slide, 0.06, \dec, 0.2, \amp, 0.85]) };
            };
            if (name == \brk) {
                // one long note per bar that slides down from the octave
                var note = chord[1][0] + 12;
                add.(b0, \ez_log, [\freq, note.midicps, \from, (note + 12).midicps, \slide, 0.25, \dec, 0.6, \amp, 0.3]);
                if (last) {
                    8.do { |k| add.(b0 + 2 + (k * 0.25), \ez_log, [\freq, (38 + [0, 3, 5, 7, 10, 12, 13, 12][k]).midicps, \from, 38.midicps, \slide, 0.03, \dec, 0.1, \amp, 0.4 + (k * 0.04)]) };
                };
            };
            if (tech) {
                logTech.do { |p, j|
                    var prev = if (j == 0) { p[1] } { logTech[j - 1][1] };
                    add.(st.(p[0]), \ez_log, [\freq, p[1].midicps, \from, prev.midicps, \slide, if (j == 0) { 0.001 } { 0.06 },
                        \dec, (secAt.(p[2] * 0.25) * 0.9).clip(0.08, 0.4), \amp, rng.(0.8, 0.92), \drive, 2.8]);
                };
            };

            // ---- electric piano chords
            if ([\intro, \found, \logA, \ret, \outro].includes(name)) {
                var cut = case
                    { name == \intro } { 1200 + (progress * 2600) }
                    { name == \outro } { 3600 - (progress * 2600) }
                    { true } { 3800 };
                var lvl = if (name == \logA or: { name == \ret }) { 0.25 } { 0.29 };
                keysRhythm[second.asInteger].do { |p|
                    chord[0].do { |n, j|
                        addDur.(st.(p[0]), p[1] * 0.25, \ez_keys,
                            [\freq, n.midicps, \amp, lvl * rng.(0.85, 1), \cut, cut, \pan, j / 3 - 0.5]);
                    };
                };
            };

            // ---- bell call motif, every four bars in the log drum sections
            if ((name == \logA or: { name == \ret }) and: { bar % 4 == 1 }) {
                bellMotif.do { |m|
                    add.(b0 + (m[0] * 0.25), \ez_bell, [\freq, m[1].midicps, \amp, 0.09, \pan, 0.3, \send, 0.35]);
                };
            };

            // ---- breakdown: pads and choir carry the chords
            if (name == \brk and: { second.not }) {
                chord[0].do { |n| addDur.(b0, 7.5, \ez_pad, [\freq, (n + 12).midicps, \amp, 0.07, \cut, 1200 + (progress * 2500)]) };
                [chord[0][0] + 12, chord[0][2] + 12].do { |n, j|
                    addDur.(b0, 7.5, \ez_choir, [\freq, n.midicps, \amp, 0.05, \vowel, 0, \pan, j - 0.5 * 0.6]);
                };
            };

            // ---- afrotech: drone, choir chant, bell arp in threes
            if (tech) {
                if (i % 4 == 0) {
                    // D, Eb, D, C, D, Eb->D
                    var roots = [38, 39, 38, 36, 38, 39];
                    var root = roots[i div: 4];
                    var prev = if (i == 0) { root } { roots[(i div: 4) - 1] };
                    addDur.(b0, 15.5, \ez_drone, [\freq, root.midicps, \from, prev.midicps, \amp, 0.11,
                        \cut, 250 + (i / 24 * 900), \cutTo, 900 + (i / 24 * 1800), \atk, if (i == 0) { 4 } { 0.3 }]);
                };
                if (i >= 4 and: { i % 2 == 0 }) {
                    // a two-note chant, "oo" then "ah"
                    addDur.(b0, 3.5, \ez_choir, [\freq, 62.midicps, \amp, 0.12, \vowel, 0, \pan, -0.3]);
                    addDur.(b0 + 4, 3, \ez_choir, [\freq, (if ((i div: 2).odd) { 63 } { 60 }).midicps, \amp, 0.12, \vowel, 1, \pan, 0.3]);
                };
                if (i >= 8) {
                    // one arp note every three 16ths, so the five-note cycle
                    // drifts against the bar; it brightens as the section goes on
                    while { arpStep * 3 < ((i + 1) * 16) } {
                        var stepInBar = (arpStep * 3) - (i * 16);
                        if (stepInBar >= 0) {
                            add.(st.(stepInBar), \ez_bell, [\freq, bellArp[arpStep % 5].midicps, \amp, 0.06 + ((i - 8) / 16 * 0.04),
                                \decay, 0.5, \bright, 0.6 + ((i - 8) / 16), \pan, [-0.4, 0.4][arpStep % 2], \send, 0.4]);
                        };
                        arpStep = arpStep + 1;
                    };
                };
                if (last) {
                    // conga roll into the return
                    16.do { |k| add.(b0 + (k * 0.25), \ez_hand, [\freq, [340, 226][k % 2], \amp, 0.3 + (k * 0.03), \pan, [0.4, -0.3][k % 2]]) };
                };
            };
            if (name == \ret and: { i % 4 == 0 }) {
                // the choir comes back softly under the chords
                addDur.(b0, 7, \ez_choir, [\freq, (chord[0][0] + 12).midicps, \amp, 0.07, \vowel, 2]);
            };

            // ---- risers and impacts
            if (name == \brk and: { i == 4 }) {
                add.(b0, \ez_riser, [\dur, secAt.(16), \amp, 0.15]);
            };
            if (name == \found and: { i == 12 }) {
                add.(b0, \ez_riser, [\dur, secAt.(16), \amp, 0.08]);
            };
            if ([\logA, \tech, \ret].includes(name) and: { i == 0 }) {
                add.(b0, \ez_impact, [\amp, 0.45]);
            };
        };
        startBar = startBar + bars;
    };
}.value;

// the last chord rings out
chords[0][0].do { |n, j| addDur.(endBeat, 6, \ez_keys, [\freq, n.midicps, \amp, 0.22, \cut, 1500, \pan, j / 3 - 0.5]) };
chords[0][0].do { |n| addDur.(endBeat, 6, \ez_pad, [\freq, (n + 12).midicps, \amp, 0.04, \cut, 1400, \atk, 0.05]) };
endSec = secAt.(endBeat) + 6;
score.add([endSec, [\c_set, 0, 0]]);

// ---------------------------------------------------------------- render

defs.do { |d| score.addFirst([0.0, [\d_recv, d.asBytes]]) };
score = Score(score.asArray.sort { |a, b| a[0] <= b[0] });

"Ezansi: % bars, % events, %:% long".format(
    totalBars, score.score.size,
    (endSec div: 60).asInteger, (endSec % 60).round.asInteger.asString.padLeft(2, "0")
).postln;

score.recordNRT(
    outputFilePath: outPath,
    sampleRate: sr,
    headerFormat: "WAV",
    sampleFormat: "int24",
    options: ServerOptions.new.numOutputBusChannels_(2).numAudioBusChannels_(128).memSize_(65536),
    duration: endSec,
    action: { "rendered %".format(outPath).postln; 0.exit }
);
)
