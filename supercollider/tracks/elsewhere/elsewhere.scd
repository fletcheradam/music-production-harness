// "Elsewhere": an original track, written in SuperCollider.
//
// Inspired by the feel of Fred again.. / Anderson .Paak / CHIKA's "places to be"
// (2024): a crisp live-sounding breakbeat, buzzy bass with a sliding sub, and
// vocal-style chops run through a delay whose speed keeps changing. No audio,
// melody or lyric from that record is used: every sound here is synthesised,
// and the chords, chop melody and bass line are new.
//
// Shape: it starts as a swung 124 BPM groove, then the tempo climbs bar by bar
// to 174 BPM and the track turns into drum and bass.
//
//   bars  1-8    intro       124      keys and chops, filtered
//   bars  9-24   groove A    124      breakbeat, buzzy bass, keys, chops
//   bars 25-32   groove B    124      more chops, delay throws
//   bars 33-48   the climb   124->174 tempo ramps, riser, the delay speeds up
//   bars 49-80   drop 1      174      two-step DnB break, reese, sub, pad stabs
//   bars 81-88   breakdown   174      pads, chops in the delay, riser
//   bars 89-104  drop 2      174      everything, plus rides and extra ghosts
//   bars 105-112 outro       174      thins out to the pad
//
// Render (no audio device needed; writes a 48 kHz / 24-bit WAV next to this file,
// or to the path given in $ELSEWHERE_OUT):
//   QT_QPA_PLATFORM=offscreen sclang elsewhere.scd
//
// Renders are deterministic: the random humanising is seeded.

(
var sr = 48000;
var here = thisProcess.nowExecutingPath.dirname;
var outPath = "ELSEWHERE_OUT".getenv ?? (here +/+ "elsewhere.wav");
var score = List.new;
var defs = List.new;
var sections, totalBars, secAt, bar2beat, add, addDur, beatsPerBar = 4;
var srcG = 1000, duckG = 999, fxG = 1001, masterG = 1002;
var mBus = 16, revBus = 18, dlyBus = 20, duckBus = 22, dlyTimeBus = 0;
var chords, chopNotes, rng, endBeat, endSec;

thisThread.randSeed = 2024;

// ---------------------------------------------------------------- synths

// Kick: pitched sine drop plus a click. Also writes its envelope to duckBus,
// so the bass and pads breathe around it.
defs.add(SynthDef(\el_kick, { |amp = 1, decay = 0.42, punch = 1|
    var env = EnvGen.ar(Env.perc(0.001, decay, 1, -5), doneAction: 2);
    var penv = EnvGen.ar(Env([5, 1.6, 1], [0.012, 0.09], [-4, -3]));
    var body = SinOsc.ar(48 * penv, 0.5pi) * env;
    var click = HPF.ar(WhiteNoise.ar, 3000) * EnvGen.ar(Env.perc(0, 0.006)) * 0.4 * punch;
    var sig = (body + click * 1.4).tanh * amp;
    Out.ar(duckBus, EnvGen.ar(Env.perc(0.002, 0.28, 1, -3)) * amp.min(1));
    Out.ar(mBus, sig ! 2);
}));

// Snare: tuned body plus band-passed noise; quiet hits make ghost notes.
defs.add(SynthDef(\el_snare, { |amp = 1, decay = 0.17, tone = 190, pan = 0|
    var env = EnvGen.ar(Env.perc(0.001, decay, 1, -4), doneAction: 2);
    var body = SinOsc.ar(tone * EnvGen.ar(Env([1.6, 1], [0.03]))) * EnvGen.ar(Env.perc(0, 0.07));
    var noise = BPF.ar(WhiteNoise.ar, 3200, 0.9) + HPF.ar(WhiteNoise.ar, 6000, 0.3);
    var sig = (body * 0.8 + (noise * env * 1.3)).tanh * amp;
    Out.ar(mBus, Pan2.ar(sig, pan));
    Out.ar(revBus, Pan2.ar(sig * 0.12, pan));
}));

// Hats: closed or open, noise through a high-pass.
defs.add(SynthDef(\el_hat, { |amp = 1, decay = 0.05, pan = 0.15, hp = 7500|
    var env = EnvGen.ar(Env.perc(0.001, decay, 1, -6), doneAction: 2);
    var sig = HPF.ar(WhiteNoise.ar + (Pulse.ar([3150, 4590, 5620], 0.5).sum * 0.2), hp) * env * amp * 0.5;
    Out.ar(mBus, Pan2.ar(sig, pan));
}));

// Ride: inharmonic partials, for drop 2.
defs.add(SynthDef(\el_ride, { |amp = 1, pan = -0.3|
    var env = EnvGen.ar(Env.perc(0.002, 0.9, 1, -5), doneAction: 2);
    var sig = HPF.ar(Mix(SinOsc.ar([2321, 3105, 4210, 5517, 6729] * 1.1, 0, 0.2)) + WhiteNoise.ar(0.15), 4000);
    Out.ar(mBus, Pan2.ar(sig * env * amp * 0.25, pan));
}));

// Buzzy bass for the groove: saw and square, low-passed, saturated, with a
// glide from the previous note (the "sliding sub").
defs.add(SynthDef(\el_buzz, { |freq = 55, from = 55, slide = 0.06, sus = 0.3, amp = 1, cut = 900|
    var f = XLine.kr(from, freq, slide.max(0.001));
    var env = EnvGen.ar(Env([0, 1, 1, 0], [0.004, sus, 0.06]), doneAction: 2);
    var osc = Saw.ar(f * [1, 1.004]).sum * 0.5 + Pulse.ar(f * 0.5, 0.4, 0.5);
    var filt = RLPF.ar(osc, cut * EnvGen.ar(Env([2.5, 1], [0.12])), 0.5);
    var sub = SinOsc.ar(f * 0.5) * 0.9;
    var duck = 1 - (In.ar(duckBus) * 0.8);
    var sig = ((filt * 1.5).tanh * 0.5 + sub) * env * amp * duck;
    Out.ar(mBus, sig ! 2);
}));

// Reese for the DnB: detuned saws with a moving low-pass, plus a pure sub.
defs.add(SynthDef(\el_reese, { |freq = 43.65, from = 43.65, slide = 0.08, sus = 1, amp = 1, wob = 0.35|
    var f = XLine.kr(from, freq, slide.max(0.001));
    var env = EnvGen.ar(Env([0, 1, 1, 0], [0.01, sus, 0.08]), doneAction: 2);
    var saws = Saw.ar(f * [1, 1.0065, 0.9932, 2.003]) * [0.5, 0.5, 0.5, 0.18];
    var cut = LFTri.kr(wob, 0).range(180, 1400);
    var mid = RLPF.ar(saws, cut, 0.35);
    var midL = (mid[0] + mid[3]) * 1.6, midR = (mid[1] + mid[2]) * 1.6;
    var sub = SinOsc.ar(f) * 0.85;
    var duck = 1 - (In.ar(duckBus) * 0.85);
    var sig = ([midL, midR].tanh * 0.45 + sub) * env * amp * duck;
    Out.ar(mBus, sig);
}));

// Keys: an FM electric piano with tremolo, for the chords in the groove.
defs.add(SynthDef(\el_keys, { |freq = 440, amp = 0.2, sus = 1, cut = 4000, pan = 0|
    var env = EnvGen.ar(Env([0, 1, 0.6, 0], [0.005, sus, 0.6], [-2, -1, -3]), doneAction: 2);
    var mod = SinOsc.ar(freq * 2) * freq * 1.2 * EnvGen.ar(Env.perc(0.001, 0.4));
    var car = SinOsc.ar(freq + mod) + (SinOsc.ar(freq * 1.002) * 0.4);
    var trem = SinOsc.kr(4.2).range(0.8, 1);
    var duck = 1 - (In.ar(duckBus) * 0.4);
    var sig = LPF.ar(car, cut) * env * trem * amp * duck;
    Out.ar(mBus, Pan2.ar(sig, pan));
    Out.ar(revBus, Pan2.ar(sig * 0.3, pan));
}));

// Pad: wide detuned saws, slow attack, for the DnB chords and the breakdown.
defs.add(SynthDef(\el_pad, { |freq = 220, amp = 0.15, sus = 2, cut = 2200, atk = 0.25|
    var env = EnvGen.ar(Env([0, 1, 1, 0], [atk, sus, 1.2], [2, 0, -3]), doneAction: 2);
    var osc = Saw.ar(freq * [0.995, 1.005, 1.0, 2.0]) * [0.4, 0.4, 0.3, 0.1];
    var sig = LPF.ar(osc, cut * LFTri.kr(0.13).range(0.7, 1.3));
    var duck = 1 - (In.ar(duckBus) * 0.7);
    sig = [sig[0] + sig[2], sig[1] + sig[3]] * env * amp * duck;
    Out.ar(mBus, sig);
    Out.ar(revBus, sig * 0.5);
}));

// Vocal-style chop: a breathy buzz through three formant filters, with a
// little pitch scoop at the start like a sung syllable. Sent hard into the
// delay, whose speed moves through the track.
defs.add(SynthDef(\el_chop, { |freq = 440, amp = 0.3, sus = 0.12, f1 = 700, f2 = 1200, f3 = 2600, pan = 0, send = 0.5|
    var env = EnvGen.ar(Env([0, 1, 0.8, 0], [0.006, sus, 0.05], [2, 0, -4]), doneAction: 2);
    var f = freq * EnvGen.kr(Env([0.94, 1], [0.04], 2)) * (1 + SinOsc.kr(5.5, 0, 0.006));
    var src = Saw.ar(f) * 0.6 + Pulse.ar(f, 0.3, 0.3) + PinkNoise.ar(0.08);
    var form = BPF.ar(src, f1, 0.12) * 1.0 + BPF.ar(src, f2, 0.1) * 0.6 + BPF.ar(src, f3, 0.08) * 0.35;
    var sig = HPF.ar(form * 5, 180) * env * amp;
    Out.ar(mBus, Pan2.ar(sig, pan));
    Out.ar(dlyBus, Pan2.ar(sig * send, pan));
}));

// Noise riser and impact.
defs.add(SynthDef(\el_riser, { |dur = 8, amp = 0.2|
    var env = EnvGen.ar(Env([0, 1, 0], [dur, 0.02], [4, -4]), doneAction: 2);
    var cut = EnvGen.kr(Env([300, 9000], [dur], \exp));
    var sig = RLPF.ar(WhiteNoise.ar ! 2, cut, 0.3) * env * amp;
    Out.ar(mBus, sig);
    Out.ar(revBus, sig * 0.4);
}));
defs.add(SynthDef(\el_impact, { |amp = 0.5|
    var env = EnvGen.ar(Env.perc(0.001, 2.5, 1, -6), doneAction: 2);
    var sig = (SinOsc.ar(EnvGen.ar(Env([90, 32], [0.4], \exp))) + (LPF.ar(WhiteNoise.ar, 2500) * 0.3)) * env * amp;
    Out.ar(mBus, sig ! 2);
    Out.ar(revBus, sig * 0.6 ! 2);
}));

// Effects: a ping-pong delay whose time follows a control bus (moving it bends
// the repeats' pitch, like speeding up a tape), and a hall reverb.
defs.add(SynthDef(\el_delay, { |fb = 0.5|
    var in = In.ar(dlyBus, 2);
    var t = Lag.kr(In.kr(dlyTimeBus), 0.4);
    var loop = LocalIn.ar(2);
    var dl = DelayC.ar(in + (loop.reverse * fb), 1.5, t);
    var shaped = LPF.ar(HPF.ar(dl, 300), 5000).tanh;
    LocalOut.ar(shaped);
    Out.ar(mBus, shaped * 0.7);
    Out.ar(revBus, shaped * 0.3);
}));
defs.add(SynthDef(\el_verb, {
    var in = In.ar(revBus, 2);
    var sig = FreeVerb2.ar(in[0], in[1], 1, 0.88, 0.4);
    Out.ar(mBus, HPF.ar(sig, 200) * 0.9);
}));

// Master: gentle glue compression, a soft clip and a limiter, out to the file.
defs.add(SynthDef(\el_master, { |gain = 1.0|
    var in = In.ar(mBus, 2) * gain;
    var comp = Compander.ar(in, in, 0.5, 1, 0.5, 0.01, 0.15);
    var sig = Limiter.ar(LeakDC.ar((comp * 1.25).tanh), 0.89, 0.01);
    Out.ar(0, sig);
}));

// ---------------------------------------------------------------- timeline

// [name, bars, start BPM, end BPM]
sections = [
    [\intro,   8,  124, 124],
    [\grooveA, 16, 124, 124],
    [\grooveB, 8,  124, 124],
    [\climb,   16, 124, 174],
    [\drop1,   32, 174, 174],
    [\brk,     8,  174, 174],
    [\drop2,   16, 174, 174],
    [\outro,   8,  174, 174],
];
totalBars = sections.collect(_[1]).sum;
endBeat = totalBars * beatsPerBar;

// Seconds at a beat, integrating the tempo through each section. A ramp is
// linear in BPM per beat, so its time is a logarithm.
secAt = { |b|
    var t = 0, startBeat = 0;
    block { |break|
        sections.do { |s|
            var beats = s[1] * beatsPerBar, t0 = s[2], t1 = s[3];
            var into = (b - startBeat).clip(0, beats);
            if (t0 == t1) {
                t = t + (into * 60 / t0);
            } {
                var k = (t1 - t0) / beats;
                t = t + (60 / k * log((t0 + (k * into)) / t0));
            };
            if (b <= (startBeat + beats)) { break.value };
            startBeat = startBeat + beats;
        };
        // past the end: carry on at the last tempo
        t = t + ((b - startBeat).max(0) * 60 / sections.last[3]);
    };
    t
};
bar2beat = { |bar| (bar - 1) * beatsPerBar };

// Schedule a synth at a beat. addDur also passes its length in seconds as sus.
add = { |beat, def, args, group = 1000|
    score.add([secAt.(beat), [\s_new, def, -1, 0, group] ++ args]);
};
addDur = { |beat, beats, def, args|
    var sus = (secAt.(beat + beats) - secAt.(beat)).max(0.02);
    add.(beat, def, [\sus, sus] ++ args);
};

// ---------------------------------------------------------------- material

// Four chords in F minor, one per bar in the groove, one per two bars in DnB:
// Fm9, Dbmaj9, Abmaj7, Eb/G. [bass midi, voicing midis]
chords = [
    [29, [56, 60, 63, 67]],
    [25, [53, 56, 60, 63]],
    [32, [55, 60, 63, 68]],
    [27, [55, 58, 63, 65]],
];

// The chop phrase: two bars of 16ths, nil = rest. [midi, vowel index]
// Vowels: 0 "ah", 1 "eh", 2 "oh", 3 "oo", 4 "ee".
chopNotes = [
    [72, 0], nil, nil, [75, 1], nil, nil, [77, 0], nil,
    [75, 2], nil, [72, 3], nil, nil, [70, 0], nil, nil,
    [72, 0], nil, nil, [75, 1], nil, [77, 4], nil, [80, 0],
    nil, [77, 2], nil, [75, 1], nil, nil, [72, 3], nil,
];

~vowels = [
    [800, 1150, 2900], [500, 1750, 2600], [450, 800, 2830],
    [325, 700, 2530], [300, 2250, 3000],
];

// ---------------------------------------------------------------- arrangement

rng = { |lo, hi| lo + 1.0.rand * (hi - lo) };

// Effect, reverb and master nodes run the whole track.
score.add([0.0, [\g_new, duckG, 0, 0]]);
score.add([0.0, [\g_new, srcG, 3, duckG]]);
score.add([0.0, [\g_new, fxG, 3, srcG]]);
score.add([0.0, [\g_new, masterG, 3, fxG]]);
score.add([0.0, [\c_set, dlyTimeBus, 60 / 124 * 0.75]]);
score.add([0.0, [\s_new, \el_delay, 2000, 0, fxG, \fb, 0.5]]);
score.add([0.0, [\s_new, \el_verb, 2001, 1, fxG]]);
score.add([0.0, [\s_new, \el_master, 2002, 0, masterG]]);

{
    var startBar = 1;
    sections.do { |s|
        var name = s[0], bars = s[1];
        bars.do { |i|
            var bar = startBar + i;
            var b0 = bar2beat.(bar);
            var isDnb = [\drop1, \drop2, \outro, \brk].includes(name);
            var groove = [\grooveA, \grooveB, \climb].includes(name);
            var last = i == (bars - 1);
            var progress = i / bars;
            var chordLen = if (isDnb) { 2 } { 1 };
            var chordIdx = ((bar - 1) div: chordLen) % 4;
            var chord = chords[chordIdx];
            var newChord = ((bar - 1) % chordLen) == 0;
            var swing = if (isDnb) { 0 } { 0.055 };
            var st = { |step| b0 + (step * 0.25) + (if (step.odd) { swing } { 0 }) };

            // ---- drums
            if (groove) {
                // swung breakbeat: kick 1 and the "and" of 3, snare 2 and 4, ghosts
                var kicks = if (bar.odd) { [0, 10] } { [0, 6, 10] };
                kicks.do { |k| add.(st.(k), \el_kick, [\amp, rng.(0.9, 1)]) };
                [4, 12].do { |k| add.(st.(k), \el_snare, [\amp, rng.(0.85, 1)]) };
                [7, 15].do { |k| add.(st.(k), \el_snare, [\amp, rng.(0.12, 0.2), \decay, 0.08, \pan, -0.2]) };
                16.do { |k|
                    var v = if (k.even) { rng.(0.6, 0.75) } { rng.(0.25, 0.4) };
                    if (k == 14) { add.(st.(k), \el_hat, [\amp, 0.6, \decay, 0.22]) } { add.(st.(k), \el_hat, [\amp, v]) };
                };
                // the climb: snare fills grow denser as the tempo rises
                if (name == \climb and: { progress > 0.5 }) {
                    var n = if (last) { 16 } { if (i.odd) { 4 } { 2 } };
                    n.do { |k| add.(b0 + 4 - (k * 0.25) - 0.25, \el_snare, [\amp, 0.25 + (0.5 * (1 - (k / n))), \decay, 0.09]) };
                };
            };
            if (name == \intro and: { i >= 4 }) {
                8.do { |k| add.(st.(k * 2), \el_hat, [\amp, rng.(0.25, 0.45)]) };
            };
            if ([\drop1, \drop2].includes(name) or: { name == \outro and: { i < 4 } }) {
                // two-step DnB: kick on 1 and the "and" of 3, snare on 2 and 4
                add.(st.(0), \el_kick, [\amp, 1]);
                add.(st.(10), \el_kick, [\amp, 0.95]);
                if (bar.even) { add.(st.(13), \el_kick, [\amp, 0.6]) };
                [4, 12].do { |k| add.(st.(k), \el_snare, [\amp, rng.(0.92, 1), \tone, 200]) };
                ([7, 9, 15] ++ (if (name == \drop2) { [2, 11] } { [] })).do { |k|
                    add.(st.(k), \el_snare, [\amp, rng.(0.1, 0.2), \decay, 0.07, \pan, rng.(-0.3, 0.3)])
                };
                16.do { |k|
                    var v = if (k.even) { rng.(0.45, 0.6) } { rng.(0.2, 0.32) };
                    add.(st.(k), \el_hat, [\amp, v, \pan, rng.(-0.2, 0.3)]);
                };
                if (name == \drop2) { 4.do { |k| add.(st.(k * 4 + 2), \el_ride, [\amp, 0.8]) } };
                if (last and: { name == \drop1 }) {
                    8.do { |k| add.(b0 + 2 + (k * 0.25), \el_snare, [\amp, 0.4 + (k * 0.07), \decay, 0.08]) };
                };
            };
            if (name == \brk and: { i >= 4 }) {
                8.do { |k| add.(st.(k * 2 + 1), \el_hat, [\amp, 0.15 + (i - 4 * 0.08)]) };
            };

            // ---- bass
            if (groove) {
                // root on 1, an octave jump, slides into the next note
                var root = chord[0] + 12;
                var pat = [[0, 3, root, root - 5], [6, 2, root + 12, root], [10, 4, root, root + 12], [14, 2, root + 3, root]];
                pat.do { |p|
                    addDur.(st.(p[0]), p[1] * 0.25, \el_buzz,
                        [\freq, p[2].midicps, \from, p[3].midicps, \slide, 0.07, \amp, 0.55,
                         \cut, if (name == \climb) { 700 + (progress * 1800) } { 800 }]);
                };
            };
            if ([\drop1, \drop2].includes(name) and: { newChord }) {
                var root = chord[0] + 12, prev = chords[(chordIdx - 1) % 4][0] + 12;
                addDur.(b0, 5.5, \el_reese, [\freq, root.midicps, \from, prev.midicps, \slide, 0.12, \amp, 0.6, \wob, 0.3]);
                addDur.(b0 + 6, 1.75, \el_reese, [\freq, (root + 7).midicps, \from, root.midicps, \slide, 0.2, \amp, 0.55, \wob, 1.1]);
            };
            if (name == \outro and: { i < 4 and: { newChord } }) {
                addDur.(b0, 7, \el_reese, [\freq, (chord[0] + 12).midicps, \from, (chord[0] + 12).midicps, \amp, 0.5]);
            };

            // ---- chords
            if ([\intro, \grooveA, \grooveB, \climb].includes(name)) {
                var cut = if (name == \intro) { 900 + (progress * 2500) } { 3800 };
                // pushed stabs: on 1, the "and" of 2, and the "e" of 4
                [[0, 5], [6, 4], [13, 3]].do { |p|
                    chord[1].do { |n, j|
                        addDur.(st.(p[0]), p[1] * 0.25, \el_keys,
                            [\freq, n.midicps, \amp, 0.07, \cut, cut, \pan, j / 3 - 0.5]);
                    };
                };
            };
            if ([\drop1, \brk, \drop2, \outro].includes(name) and: { newChord }) {
                chord[1].do { |n|
                    addDur.(b0, 7.5, \el_pad, [\freq, (n + 12).midicps, \amp, if (name == \brk) { 0.2 } { 0.05 },
                        \cut, if (name == \brk) { 1200 + (progress * 3000) } { 2600 }, \atk, if (name == \brk) { 0.8 } { 0.05 }]);
                };
            };

            // ---- chops
            if ([\intro, \grooveB, \climb, \drop1, \brk, \drop2].includes(name) or: { name == \grooveA and: { i >= 8 } }) {
                var phrase = chopNotes.copyRange((bar.odd.not.asInteger) * 16, (bar.odd.not.asInteger) * 16 + 15);
                var sparse = (name == \intro and: { i < 4 }) or: { name == \drop1 and: { bar.odd } };
                phrase.do { |c, k|
                    if (c.notNil and: { sparse.not or: { k < 8 } }) {
                        var v = ~vowels[c[1]];
                        addDur.(st.(k), 0.4, \el_chop,
                            [\freq, c[0].midicps, \f1, v[0], \f2, v[1], \f3, v[2], \amp, 0.22,
                             \pan, rng.(-0.35, 0.35), \send, if (name == \brk) { 0.9 } { 0.45 }]);
                    };
                };
            };

            // ---- the delay's speed: a dotted eighth that follows the tempo in the
            // climb, then lurches between speeds in the breakdown
            if (name == \climb) {
                4.do { |q|
                    var bt = b0 + q;
                    var bpm = 124 + (50 * ((i * 4 + q) / (bars * 4)));
                    score.add([secAt.(bt), [\c_set, dlyTimeBus, 60 / bpm * 0.75]]);
                };
            };
            if (name == \drop1 and: { i == 0 }) { score.add([secAt.(b0), [\c_set, dlyTimeBus, 60 / 174 * 0.75]]) };
            if (name == \brk) {
                score.add([secAt.(b0), [\c_set, dlyTimeBus, [0.75, 0.375, 1.0, 0.25][i % 4] * 60 / 174 * 2]]);
                score.add([secAt.(b0), [\n_set, 2000, \fb, 0.72]]);
            };
            if (name == \drop2 and: { i == 0 }) {
                score.add([secAt.(b0), [\c_set, dlyTimeBus, 60 / 174 * 0.75]]);
                score.add([secAt.(b0), [\n_set, 2000, \fb, 0.5]]);
            };

            // ---- risers and impacts
            if (name == \climb and: { i == 8 }) {
                add.(b0, \el_riser, [\dur, secAt.(b0 + 32) - secAt.(b0), \amp, 0.16]);
            };
            if (name == \brk and: { i == 4 }) {
                add.(b0, \el_riser, [\dur, secAt.(b0 + 16) - secAt.(b0), \amp, 0.16]);
            };
            if ([\drop1, \drop2].includes(name) and: { i == 0 }) {
                add.(b0, \el_impact, [\amp, 0.55]);
            };
        };
        startBar = startBar + bars;
    };
}.value;

// the final chord rings out
chords[0][1].do { |n| addDur.(endBeat, 8, \el_pad, [\freq, (n + 12).midicps, \amp, 0.06, \atk, 0.02, \cut, 1800]) };
endSec = secAt.(endBeat) + 7;
score.add([endSec, [\c_set, 0, 0]]);

// ---------------------------------------------------------------- render

defs.do { |d| score.addFirst([0.0, [\d_recv, d.asBytes]]) };
score = Score(score.asArray.sort { |a, b| a[0] <= b[0] });

"Elsewhere: % bars, % events, %:% long".format(
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
