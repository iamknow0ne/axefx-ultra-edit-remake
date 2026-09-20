# Effect and control reference

[Documentation index](README.md) · [Editing guide](USER-GUIDE.md#editing-an-effect)

Generated from the shipped interoperability catalog: **36 families, 69 instances, 922 definitions**. This is a control inventory, not proof of all-controls hardware acceptance. Display ranges and units are catalog estimates; raw defaults are bytes, not physical units. Names marked spare may not be editable. Noise Gate, Output and Controllers use complete preset transfers, applied on release; direct live queries remain disabled. Firmware/model-specific meanings can differ.

The editor pages, filters, menus and modifier availability come from these definitions. Change supported controls in the inspector; do not send raw values from this reference directly to hardware. For model initialization, global controls and offline restrictions, see the user guide.

## Families

- [Amp](#amp)
- [Cab](#cab)
- [Chorus](#chorus)
- [Compressor](#compressor)
- [Crossover](#crossover)
- [Delay](#delay)
- [Drive](#drive)
- [Enhancer](#enhancer)
- [FeedbackReturn](#feedbackreturn)
- [Filter](#filter)
- [Flanger](#flanger)
- [Formant](#formant)
- [GateExpander](#gateexpander)
- [GraphicEQ](#graphiceq)
- [EffectsLoop](#effectsloop)
- [MegaTap](#megatap)
- [Mixer](#mixer)
- [MultibandComp](#multibandcomp)
- [MultiDelay](#multidelay)
- [ParametricEQ](#parametriceq)
- [Phaser](#phaser)
- [Pitch](#pitch)
- [QuadChorus](#quadchorus)
- [Resonator](#resonator)
- [Reverb](#reverb)
- [RingMod](#ringmod)
- [Rotary](#rotary)
- [Synth](#synth)
- [Vocoder](#vocoder)
- [VolPan](#volpan)
- [PanTrem](#pantrem)
- [Wah](#wah)
- [NoiseGate](#noisegate)
- [Output](#output)
- [Controllers](#controllers)
- [FeedbackSend](#feedbacksend)

## Amp

**Amp** · Instances: Amp 1 (ID 106), Amp 2 (ID 107)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Amp model | Basic | 0–70 | — | 0 | — |
| 1 | Drive | Basic | 0–10 | — | 152 | 203 |
| 2 | Bass | Basic | 0–10 | — | 127 | — |
| 3 | Mid | Basic | 0–10 | — | 127 | — |
| 4 | Treb | Basic | 0–10 | — | 127 | — |
| 20 | Presence | Basic | -10–10 | — | 127 | — |
| 5 | Master Vol | Basic | 0–10 | — | 127 | 207 |
| 31 | Global | Basic | 0–10 | — | 0 | — |
| 21 | Level | Basic | -50–13.5 | dB | 200 | 201 |
| 22 | Balance | Basic | -50–50 | — | 127 | 202 |
| 23 | Bypass Mode | Basic | 0–1 | — | 0 | 255 |
| 15 | Input Select | Advanced | 0–2 | — | 2 | — |
| 16 | Depth | Advanced | 0–10 | — | 76 | — |
| 24 | Damp | Advanced | 0–10 | — | 127 | — |
| 19 | Sag | Advanced | 0–10 | — | 51 | — |
| 29 | Warmth | Advanced | 0–10 | — | 0 | — |
| 30 | Thump | Advanced | 0–10 | — | 0 | — |
| 6 | Low Cut | Advanced | 10–1000 | Hz | 221 | — |
| 7 | Hi Cut | Advanced | 2000–20000 | Hz | 138 | — |
| 36 | Power Tube Bias | Amp Geek | 0–1 | — | 89 | — |
| 26 | Spkr Res Freq | Amp Geek | 50–500 | Hz | 71 | — |
| 12 | XFormer Low Freq | Amp Geek | 10–1000 | Hz | 89 | — |
| 13 | XFormer Hi Freq | Amp Geek | 2000–20000 | Hz | 222 | — |
| 27 | Low Freq Resonance | Amp Geek | 0–10 | — | 127 | — |
| 38 | Hi Freq Resonance | Amp Geek | 0–10 | — | 0 | — |
| 35 | B+ Cap | Amp Geek | 0–10 | — | 110 | — |
| 10 | Bright Cap | Amp Geek | 0.1–10 | nF | 43 | — |
| 33 | Stabilizer | Amp Geek | 0–1 | — | 0 | — |
| 8 | Tone Freq | Amp Geek | 200–2000 | Hz | 121 | — |
| 14 | Tone Location | Amp Geek | 0–2 | — | 1 | — |
| 34 | Tonestack Type | Amp Geek | 0–28 | — | 1 | — |
| 25 | Presence Freq | Amp Geek | 500–5000 | Hz | 101 | — |
| 37 | Pres/Depth Type | Amp Geek | 0–3 | — | 0 | — |
| 9 | Tonespace | Other | 1.5–4 | — | 91 | — |
| 11 | Wslpf | Other | 400–40000 | Hz | 139 | — |
| 17 | Offset | Other | -1–1 | — | 140 | — |
| 18 | Cliptype2 | Other | 0–9 | — | 9 | — |
| 28 | Flags | Other | 1–1 | — | 0 | — |
| 32 | Wshpf | Other | 2–200 | Hz | 69 | — |

**Amp model choices** (catalog order): TUBE PRE, JAZZ, BROWNFACE, 59 BASSGUY, DELUXE VERB, DOUBLE VERB, CLASS A, TOP BOOST, PLEXI 1, BRIT 800, BRIT 900, BROWN, BOUTIQUE 1, BOUTIQUE 2, HIPOWER 1, HIPOWER 2, USA CLEAN, USA RHY 1, USA RHY 2, USA LEAD 1, USA LEAD 2, RECTO ORANGE, RECTO RED, SOLO 100, SPEC. OD 1, SPEC. OD 2, EURO BLUE, EURO RED, UK GC30, BUTTERY, METAL, BIG HAIR, HELLBEAST, SUPERTWEED, FUSION, FAS CLEAN, FAS CRUNCH, FAS LEAD 1, FAS LEAD 2, FAS MODERN, JR BLUES, BRIT PRE, RECTO NEW, ENERGYBALL, HAD ODS 1, WRECKER 1, BRIT JM45, DAS METALL, PLEXI 2, SV BASS, CA3+ RHY, CA3+ LD, EGGIE R20, USA IIC+ 1, USA IIC+ 2, FRYETTE D60L, FRYETTE D60M, MR Z 38 SR, EURO UBER, PVH 5105, SOLO 99 CLN, SOLO 99 RHY, SOLO 99 LD, CORNCOB R100, CAROLANN OD2, CITRUS RV50, SHIVER CLN, SHIVER LD, 1987X MOD, MARSHA BE, MARSHA HBE.

**Global choices** (catalog order): OFF, GLOBAL 1, GLOBAL 2, GLOBAL 3, GLOBAL 4, GLOBAL 5, GLOBAL 6, GLOBAL 7, GLOBAL 8, GLOBAL 9, GLOBAL 10.

**Bypass Mode choices** (catalog order): THRU, MUTE.

**Input Select choices** (catalog order): LEFT, RIGHT, SUM L+R.

**Stabilizer choices** (catalog order): OFF, ON.

**Tone Location choices** (catalog order): PRE, POST, END.

**Tonestack Type choices** (catalog order): ACTIVE, PASSIVE, BROWNFACE, BLACKFACE, BLUES, TOP BOOST, PLEXI, BOUTIQUE, HI POWER, USA CLEAN, USA LEAD, RECTO ORG, RECTO RED, SKYLINE, GERMAN, BLUES JR, WRECKER, VINTAGE, CA3+SE, FREYER D60, MR Z 38 SR, EURO UBER, PVH 5105, SOLO X99, CORNCOB, EURO, CAROLANN, CITRUS, BRIT JM45.

**Pres/Depth Type choices** (catalog order): PASSIVE, ACTIVE, ACTIVE PRES, ACTIVE DEPTH.

**Cliptype2 choices** (catalog order): 0, 1, 2, 3, 4, 5, 6, 7, 8, 9.

**Flags switch metadata:** `[{"name": "Boost", "bit": 3}, {"name": "Bright", "bit": 1}]`.

## Cab

**Cab** · Instances: Cabinet 1 (ID 108), Cabinet 2 (ID 109)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 12 | Type | Basic | 0–2 | — | 0 | — |
| 0 | Cab | Cabinet | 0–48 | — | 7 | — |
| 1 | Mic | Cabinet | 0–10 | — | 0 | — |
| 14 | Drive | Cabinet | 0–10 | — | 0 | — |
| 16 | Air | Cabinet | 0–100 | % | 0 | — |
| 9 | Level | Cabinet | -50–13.5 | dB | 200 | 201 |
| 10 | Balance | Cabinet | -50–50 | — | 127 | 202 |
| 17 | Air Freq | Cabinet | 1000–10000 | Hz | 0 | — |
| 11 | Bypass Mode | Cabinet | 0–1 | — | 0 | 255 |
| 4 | Link | Cabinet | 0–1 | — | 1 | — |
| 5 | Level L | Cabinet | -80–0 | dB | 254 | — |
| 7 | Pan L | Cabinet | -50–50 | — | 64 | — |
| 2 | Cab R | Cabinet | 0–48 | — | 7 | — |
| 3 | Mic R | Cabinet | 0–10 | — | 0 | — |
| 6 | Level R | Cabinet | -80–0 | dB | 254 | — |
| 8 | Pan R | Cabinet | -50–50 | — | 191 | — |
| 15 | Drive R | Cabinet | 0–10 | — | 0 | — |
| 13 | Bypass | Other | 12483–12483 | Hz | 0 | — |

**Type choices** (catalog order): MONO HIRES, MONO LORES, STEREO.

**Cab choices** (catalog order): 1x6 OVAL, 1x8 TWEED, 1x10 GOLD, 1x10 BLUE, 1x12 TWEED, 1x12 BLACK, 1x12 BRIT, 1x12 E12L, 1x12 STUDIO, 1x12 OPEN, 1x12 BLUES, 1x15 BLUES, 2x12 BLACK, 2x12 BRIT, 2x12 CUST, 2x12 TWEED, 2x12 BOUTIQ, 2x12 GOLD, 2x12 G12H, 2x12 BLUE, 4x10 BASS, 4x12 RECTO1, 4x12 RECTO2, 4x12 BRIT, 4x12 20W, 4x12 25W, 4x12 75W, 4x12 30W, 4x12 GREEN, 4x12 V30, 4x12 T75, 4x12 GERMAN, 4x12 METAL, 4x12 JM2000, 4x12 SOUTH, 4x12 CALI, 4x10 ALUM, 8x10 BASS, 1x15 SRBASS, USER 1, USER 2, USER 3, USER 4, USER 5, USER 6, USER 7, USER 8, USER 9, USER 10.

**Mic choices** (catalog order): NONE, 57 DYN, 58 DYN, 421 DYN, 87A COND, U87 COND, E609 DYN, RE16 DYN, R121 COND, D112 DYN, 67 COND.

**Bypass Mode choices** (catalog order): THRU, MUTE.

**Link choices** (catalog order): OFF, ON.

**Cab R choices** (catalog order): 1x6 OVAL, 1x8 TWEED, 1x10 GOLD, 1x10 BLUE, 1x12 TWEED, 1x12 BLACK, 1x12 BRIT, 1x12 E12L, 1x12 STUDIO, 1x12 OPEN, 1x12 BLUES, 1x15 BLUES, 2x12 BLACK, 2x12 BRIT, 2x12 CUST, 2x12 TWEED, 2x12 BOUTIQ, 2x12 GOLD, 2x12 G12H, 2x12 BLUE, 4x10 BASS, 4x12 RECTO1, 4x12 RECTO2, 4x12 BRIT, 4x12 20W, 4x12 25W, 4x12 75W, 4x12 30W, 4x12 GREEN, 4x12 V30, 4x12 T75, 4x12 GERMAN, 4x12 METAL, 4x12 JM2000, 4x12 SOUTH, 4x12 CALI, 4x10 ALUM, 8x10 BASS, 1x15 SRBASS, USER 1, USER 2, USER 3, USER 4, USER 5, USER 6, USER 7, USER 8, USER 9, USER 10.

**Mic R choices** (catalog order): NONE, 57 DYN, 58 DYN, 421 DYN, 87A COND, U87 COND, E609 DYN, RE16 DYN, R121 COND, D112 DYN, 67 COND.

## Chorus

**Chorus** · Instances: Chorus 1 (ID 116), Chorus 2 (ID 117)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Rate | Chorus | 0–10 | Hz | 128 | 203 |
| 2 | Tempo | Chorus | 0–29 | — | 0 | — |
| 10 | LFO Type | Chorus | 0–8 | — | 0 | — |
| 9 | LFO Phase | Chorus | 0–180 | deg | 0 | — |
| 20 | LFO2 Rate | Chorus | 0.05–2 | Hz | 0 | — |
| 3 | Depth | Chorus | 0–100 | % | 64 | 204 |
| 8 | Delay time | Chorus | 1–50 | ms | 98 | — |
| 0 | Voices | Chorus | 1–4 | — | 1 | — |
| 19 | Width | Chorus | 0–100 | % | 0 | — |
| 11 | Auto depth | Chorus | 0–2 | — | 1 | — |
| 18 | Phase Reverse | Chorus | 0–1 | — | 0 | — |
| 21 | LFO2 Depth | Chorus | 0–100 | % | 0 | — |
| 12 | Mix | Chorus | 0–100 | % | 64 | 200 |
| 13 | Level | Chorus | -50–13.5 | dB | 200 | 201 |
| 14 | Balance | Chorus | -50–50 | — | 127 | 202 |
| 15 | Bypass Mode | Chorus | 0–2 | — | 0 | 255 |
| 6 | Bass Freq | Tone | 100–1000 | Hz | 76 | — |
| 4 | Bass | Tone | -12–12 | dB | 127 | — |
| 7 | Treble Freq | Tone | 1000–10000 | Hz | 178 | — |
| 5 | Treble | Tone | -12–12 | dB | 127 | — |
| 22 | Hicut Freq | Tone | 200–20000 | Hz | 254 | — |
| 16 | Globalmix | Other | 0–1 | — | 0 | — |
| 17 | Flags | Other | -50–-50 | — | 0 | — |

**Tempo choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**LFO Type choices** (catalog order): SINE, TRIANGLE, SQUARE, SAW UP, SAW DOWN, RANDOM, LOG, EXP, TRAPEZOID.

**Voices choices** (catalog order): 2, 4, 6, 8.

**Auto depth choices** (catalog order): OFF, LOW, HIGH.

**Phase Reverse choices** (catalog order): OFF, ON.

**Bypass Mode choices** (catalog order): MIX = 0%, MUTE FX OUT, MUTE OUT.

**Globalmix choices** (catalog order): OFF, ON.

## Compressor

**Compressor** · Instances: Compressor 1 (ID 100), Compressor 2 (ID 101)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 12 | Type | Basic | 0–1 | — | 0 | — |
| 0 | Threshold | Studio | -80–0 | dB | 127 | — |
| 7 | Detect | Studio | 0–2 | — | 0 | — |
| 1 | Ratio | Studio | 1–20 | — | 59 | — |
| 5 | Knee | Studio | 0–3 | — | 1 | — |
| 6 | Makeup | Studio | 0–1 | — | 1 | — |
| 2 | Attack | Studio | 0–10 | — | 127 | — |
| 3 | Release | Studio | 0–10 | — | 127 | — |
| 8 | Filter | Studio | 10–1000 | Hz | 0 | — |
| 10 | Sidechain Select | Studio | 0–6 | — | 0 | — |
| 15 | Auto | Studio | 0–1 | — | 1 | — |
| 14 | Look-Ahead | Studio | 0–2 | ms | 64 | — |
| 11 | Mix | Studio | 0–100 | % | 254 | 200 |
| 4 | Level | Studio | -20–20 | dB | 127 | — |
| 13 | Bypass Mode | Studio | 0–2 | — | 0 | 255 |
| 9 | Bypass | Other | 0–0 | — | 0 | — |

**Type choices** (catalog order): STUDIO, PEDAL.

**Detect choices** (catalog order): RMS, PEAK, RMS+PEAK.

**Knee choices** (catalog order): HARD, SOFT, SOFTER, SOFTEST.

**Makeup choices** (catalog order): OFF, ON.

**Sidechain Select choices** (catalog order): NONE, ROW 1, ROW 2, ROW 3, ROW 4, INPUT 1, INPUT 2.

**Auto choices** (catalog order): OFF, ON.

**Bypass Mode choices** (catalog order): MIX = 0%, MUTE FX OUT, MUTE OUT.

## Crossover

**Crossover** · Instances: Crossover 1 (ID 148), Crossover 2 (ID 149)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | Lo Level L | Crossover | -80–0 | dB | 254 | — |
| 4 | Lo Level R | Crossover | -80–0 | dB | 254 | — |
| 0 | Freq | Crossover | 40–800 | Hz | 78 | — |
| 1 | Freq Multiplier | Crossover | 0–1 | — | 0 | — |
| 3 | Hi level L | Crossover | -80–0 | dB | 254 | — |
| 5 | Hi Level R | Crossover | -80–0 | dB | 254 | — |
| 6 | Lo Pan L | Crossover | -50–50 | — | 0 | — |
| 8 | Lo Pan R | Crossover | -50–50 | — | 254 | — |
| 7 | Hi Pan L | Crossover | -50–50 | — | 0 | — |
| 9 | Hi Pan R | Crossover | -50–50 | — | 254 | — |
| 11 | Level | Crossover | -50–13.5 | dB | 200 | 201 |
| 12 | Balance | Crossover | -50–50 | — | 127 | 202 |
| 13 | Bypassmode | Crossover | 0–1 | — | 0 | 255 |
| 10 | Mix | Other | 0–0 | % | 0 | 200 |
| 14 | Bypass | Other | -50–-50 | — | 0 | — |

**Freq Multiplier choices** (catalog order): X 1, X 10.

**Bypassmode choices** (catalog order): THRU, MUTE.

## Delay

**Delay** · Instances: Delay 1 (ID 112), Delay 2 (ID 113)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Type | Basic | 0–5 | — | 1 | — |
| 1 | Time | Time/FB | 31–7968 | ms | 15 | 203 |
| 9 | Tempo | Time/FB | 0–29 | — | 0 | — |
| 4 | Feedback | Time/FB | 0–100 | % | 25 | 205 |
| 7 | Echo Pan | Time/FB | -50–50 | — | 127 | 206 |
| 48 | Phase Reverse | Time/FB | 0–1 | — | 0 | — |
| 17 | Mix | Time/FB | 0–100 | % | 38 | 200 |
| 18 | Level | Time/FB | -50–13.5 | dB | 200 | 201 |
| 19 | Balance | Time/FB | -50–50 | — | 127 | 202 |
| 23 | Input Gain | Time/FB | 0–100 | % | 254 | 208 |
| 20 | Bypass Mode | Time/FB | 0–4 | — | 0 | 255 |
| 10 | Low Cut | Tone/Duck | 20–2000 | Hz | 0 | — |
| 11 | High Cut | Tone/Duck | 200–20000 | Hz | 254 | — |
| 41 | Filter Slope | Tone/Duck | 0–2 | — | 0 | — |
| 42 | Ducker Attenuation | Tone/Duck | 0–80 | dB | 0 | — |
| 43 | Ducker Threshold | Tone/Duck | -80–0 | dB | 127 | — |
| 44 | Ducker Release | Tone/Duck | 1–1000 | ms | 85 | — |
| 16 | Drive | Tone/Duck | 0–10 | — | 0 | — |
| 46 | Diffusion | Tone/Duck | 0–100 | % | 0 | — |
| 47 | Diff Time | Tone/Duck | 10–100 | % | 113 | — |
| 12 | LFO1 Rate | Mod 1 | 0.1–10 | Hz | 89 | — |
| 51 | LFO1 Tempo | Mod 1 | 0–29 | — | 0 | — |
| 24 | LFO1 Type | Mod 1 | 0–8 | — | 0 | — |
| 14 | LFO1 Depth | Mod 1 | 0–100 | % | 0 | — |
| 45 | Depth Range | Mod 1 | 0–1 | — | 0 | — |
| 36 | LFO1 Phase | Mod 1 | 0–180 | deg | 0 | — |
| 49 | LFO1 Target | Mod 1 | 0–2 | — | 0 | — |
| 13 | LFO2 Rate | Mod 2 | 0.2–20 | Hz | 178 | — |
| 52 | LFO2 Tempo | Mod 2 | 0–29 | — | 0 | — |
| 25 | LFO2 Type | Mod 2 | 0–8 | — | 0 | — |
| 15 | LFO2 Depth | Mod 2 | 0–100 | % | 0 | — |
| 37 | LFO2 Phase | Mod 2 | 0–180 | deg | 0 | — |
| 50 | LFO2 Target | Mod 2 | 0–2 | — | 0 | — |
| 3 | Ratio | Time/FB | 1–100 | % | 254 | — |
| 5 | Feedback L | Time/FB | 0–100 | % | 25 | — |
| 28 | Master Feedback | Time/FB | 0–100 | % | 254 | 213 |
| 8 | Spread (Width) | Time/FB | -100–100 | % | 254 | 207 |
| 6 | Feedback R | Time/FB | 0–100 | % | 25 | — |
| 31 | Feedback R>L | Time/FB | 0–100 | % | 0 | — |
| 32 | Level L | Time/FB | 0–100 | % | 254 | 211 |
| 34 | Pan L | Time/FB | -50–50 | — | 0 | — |
| 26 | Time R | Time/FB | 31–7968 | ms | 15 | 204 |
| 29 | Tempo R | Time/FB | 0–29 | — | 0 | — |
| 30 | Feedback L>R | Time/FB | 0–100 | % | 0 | — |
| 33 | Level R | Time/FB | 0–100 | % | 254 | 212 |
| 35 | Pan R | Time/FB | -50–50 | — | 254 | — |
| 38 | XFade Time | Time/FB | 1–255 | ms | 9 | — |
| 39 | Run | Time/FB | 0–1 | — | 1 | 209 |
| 40 | Trigger Restart | Time/FB | 0–1 | — | 0 | — |
| 54 | Record | Looper | 15–15 | — | 15 | — |
| 55 | Play | Looper | 248–248 | — | 248 | — |
| 56 | Once | Looper | 0–0 | — | 254 | — |
| 57 | Stack | Looper | 25–25 | — | 25 | — |
| 58 | Reverse | Looper | 25–25 | — | 25 | — |
| 2 | Fine | Other | 200–200 | Hz | 248 | — |
| 21 | Globalmix | Other | 0–1 | — | 0 | — |
| 22 | Bypass | Other | 0–0 | — | 0 | — |
| 27 | Finer | Other | 5–5 | — | 248 | — |
| 53 | End | Other | 1–1 | — | 1 | — |

**Type choices** (catalog order): MONO, STEREO, PING-PONG, DUAL, REVERSE, LOOPER.

**Tempo choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**Phase Reverse choices** (catalog order): OFF, ON.

**Bypass Mode choices** (catalog order): MIX = 0%, MUTE FX OUT, MUTE OUT, MUTE FX IN, MUTE IN.

**Filter Slope choices** (catalog order): 6 dB/OCT, 12 dB/OCT, 18 dB/OCT.

**LFO1 Tempo choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**LFO1 Type choices** (catalog order): SINE, TRIANGLE, SQUARE, SAW UP, SAW DOWN, RANDOM, LOG, EXP, TRAPEZOID.

**Depth Range choices** (catalog order): LOW, HIGH.

**LFO1 Target choices** (catalog order): BOTH, LEFT, RIGHT.

**LFO2 Tempo choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**LFO2 Type choices** (catalog order): SINE, TRIANGLE, SQUARE, SAW UP, SAW DOWN, RANDOM, LOG, EXP, TRAPEZOID.

**LFO2 Target choices** (catalog order): BOTH, LEFT, RIGHT.

**Tempo R choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**Run choices** (catalog order): OFF, ON.

**Trigger Restart choices** (catalog order): OFF, ON.

**Record choices** (catalog order): 4, 4.

**Play choices** (catalog order): INFINITE, INFINITE.

**Stack choices** (catalog order): 1/4, 1/4.

**Reverse choices** (catalog order): 0, 0.

**Globalmix choices** (catalog order): OFF, ON.

**End choices** (catalog order): 1, 1.

## Drive

**Drive** · Instances: Drive 1 (ID 133), Drive 2 (ID 134)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Type | Basic | 0–21 | — | 0 | — |
| 1 | Drive | Drive | 0–10 | — | 127 | 201 |
| 2 | Tone | Drive | 0–10 | — | 127 | 202 |
| 8 | Low Cut | Drive | 20–2000 | Hz | 196 | — |
| 9 | High Cut | Drive | 200–20000 | Hz | 76 | — |
| 10 | Clip Type | Drive | 0–7 | — | 6 | — |
| 6 | Slew Limit | Drive | 0–10 | — | 178 | 204 |
| 11 | Bias | Drive | -1–1 | — | 128 | — |
| 12 | Bass | Drive | -12–12 | dB | 127 | — |
| 14 | Mid Freq | Drive | 200–2000 | Hz | 128 | — |
| 13 | Mid | Drive | -12–12 | dB | 127 | — |
| 15 | Treble | Drive | -12–12 | dB | 127 | — |
| 4 | Mix | Drive | 0–100 | % | 254 | 200 |
| 3 | Level | Drive | 0–10 | — | 127 | 203 |
| 5 | Bypass Mode | Drive | 0–2 | — | 0 | 255 |
| 7 | Bypass | Other | 0.1–0.1 | — | 0 | — |

**Type choices** (catalog order): RAT DIST, PI FUZZ, TUBE DRIVE, SUPER OD, TREB BOOST, MID BOOST, T808 OD, FAT RAT, T808 MOD, OCTV DIST, PLUS DIST, HARD FUZZ, FET BOOST, TAPE DIST, FULL OD, BLUES OD, SHRED DIST, M-ZONE DIST, BENDER FUZZ, BB PRE, MASTER FUZZ, FACE FUZZ.

**Clip Type choices** (catalog order): LV TUBE, HARD, SOFT, GE DIODE, FW RECT, HV TUBE, SI DIODE, 4558/DIODE.

**Bypass Mode choices** (catalog order): MIX = 0%, MUTE FX OUT, MUTE OUT.

## Enhancer

**Enhancer** · Instances: Enhancer (ID 135)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Width | Enhancer | 0–100 | % | 51 | — |
| 1 | Invert | Enhancer | 0–3 | — | 0 | — |
| 4 | Pan Left | Enhancer | -50–50 | — | 0 | — |
| 5 | Pan Right | Enhancer | -50–50 | — | 254 | — |
| 2 | Balance | Enhancer | -50–50 | — | 127 | — |
| 3 | Bypass | Other | 0–0 | — | 0 | — |

**Invert choices** (catalog order): NONE, LEFT, RIGHT, BOTH.

## FeedbackReturn

**FeedbackReturn** · Instances: Feedback Return (ID 143)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Mix | FB Return | 0–100 | % | 0 | 200 |
| 1 | Level | FB Return | -50–13.5 | dB | 200 | 201 |
| 2 | Balance | FB Return | -50–50 | — | 127 | 202 |
| 3 | Bypass Mode | FB Return | 0–2 | — | 0 | 255 |
| 4 | Globalmix | Other | 0–1 | — | 0 | — |
| 5 | Bypass | Other | 1–1 | TRIP | 0 | — |

**Bypass Mode choices** (catalog order): MIX = 0%, MUTE FX OUT, MUTE OUT.

**Globalmix choices** (catalog order): OFF, ON.

## Filter

**Filter** · Instances: Filter 1 (ID 131), Filter 2 (ID 132), Filter 3 (ID 164), Filter 4 (ID 165)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Type | Filter | 0–7 | — | 0 | — |
| 3 | Gain | Filter | -12–12 | dB | 127 | 202 |
| 1 | Frequency | Filter | 20–20000 | Hz | 144 | 200 |
| 2 | Q | Filter | 0.1–10 | — | 108 | 201 |
| 7 | Roffs | Filter | 0.1–1 | — | 254 | — |
| 9 | Pan Left | Filter | -50–50 | — | 0 | — |
| 5 | Balance | Filter | -50–50 | — | 127 | 204 |
| 4 | Level | Filter | -20–20 | dB | 127 | 203 |
| 10 | Pan Right | Filter | -50–50 | — | 254 | — |
| 6 | Bypass Mode | Filter | 0–1 | — | 0 | 255 |
| 8 | Bypass | Other | -50–-50 | ct | 0 | — |

**Type choices** (catalog order): NULL, LOWPASS, BANDPASS, HIGHPASS, LOWSHELF, HIGHSHLF, PEAKING, NOTCH.

**Bypass Mode choices** (catalog order): THRU, MUTE.

## Flanger

**Flanger** · Instances: Flanger 1 (ID 118), Flanger 2 (ID 119)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Rate | Flanger | 0.049–10 | Hz | 144 | 203 |
| 1 | Tempo | Flanger | 0–29 | — | 0 | — |
| 11 | LFO Type | Flanger | 0–8 | — | 0 | — |
| 10 | LFO Phase | Flanger | 0–180 | deg | 0 | — |
| 12 | LFO Hicut | Flanger | 1–100 | Hz | 216 | — |
| 2 | Depth | Flanger | 0–100 | % | 64 | 204 |
| 8 | Delay Time | Flanger | 0–10 | ms | 25 | — |
| 3 | Feedback | Flanger | -99.5–99.5 | % | 191 | 205 |
| 9 | Manual | Flanger | 0–100 | % | 0 | 206 |
| 13 | Auto depth | Flanger | 0–2 | — | 1 | — |
| 21 | Dry Delay | Flanger | 0–10 | ms | 0 | — |
| 20 | Phase Reverse | Flanger | 0–3 | — | 0 | — |
| 14 | Mix | Flanger | 0–100 | % | 127 | 200 |
| 15 | Level | Flanger | -50–13.5 | dB | 200 | 201 |
| 16 | Balance | Flanger | -50–50 | — | 127 | 202 |
| 17 | Bypass Mode | Flanger | 0–2 | — | 0 | 255 |
| 6 | Bass Freq | Tone | 100–1000 | Hz | 76 | — |
| 4 | Bass | Tone | -12–12 | dB | 127 | — |
| 7 | Treble Freq | Tone | 1000–10000 | Hz | 178 | — |
| 5 | Treble | Tone | -12–12 | dB | 127 | — |
| 22 | Hi Cut Freq | Tone | 200–20000 | Hz | 254 | — |
| 18 | Globalmix | Other | 0–1 | — | 0 | — |
| 19 | Flags | Other | 0–0 | % | 0 | — |

**Tempo choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**LFO Type choices** (catalog order): SINE, TRIANGLE, SQUARE, SAW UP, SAW DOWN, RANDOM, LOG, EXP, TRAPEZOID.

**Auto depth choices** (catalog order): OFF, LOW, HIGH.

**Phase Reverse choices** (catalog order): NONE, RIGHT, LEFT, BOTH.

**Bypass Mode choices** (catalog order): MIX = 0%, MUTE FX OUT, MUTE OUT.

**Globalmix choices** (catalog order): OFF, ON.

## Formant

**Formant** · Instances: Formant (ID 126)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 4 | Control | Formant | 0–100 | % | 0 | 203 |
| 3 | Resonance | Formant | 0–10 | — | 76 | 204 |
| 0 | Start | Formant | 0–9 | — | 0 | — |
| 1 | Mid | Formant | 0–9 | — | 1 | — |
| 2 | End | Formant | 0–9 | — | 2 | — |
| 5 | Mix | Formant | 0–100 | % | 254 | 200 |
| 6 | Level | Formant | -50–13.5 | dB | 200 | 201 |
| 7 | Balance | Formant | -50–50 | — | 127 | 202 |
| 8 | Bypass Mode | Formant | 0–2 | — | 0 | 255 |
| 9 | Globalmix | Other | 0–1 | — | 0 | — |
| 10 | Spare | Other | -50–-50 | dB | 0 | — |
| 11 | Bypass | Other | -50–-50 | — | 0 | — |

**Start choices** (catalog order): AAA, EEE, III, OHH, OOO, EHH, AHH, AWW, UHH, ERR.

**Mid choices** (catalog order): AAA, EEE, III, OHH, OOO, EHH, AHH, AWW, UHH, ERR.

**End choices** (catalog order): AAA, EEE, III, OHH, OOO, EHH, AHH, AWW, UHH, ERR.

**Bypass Mode choices** (catalog order): MIX = 0%, MUTE FX OUT, MUTE OUT.

**Globalmix choices** (catalog order): OFF, ON.

## GateExpander

**GateExpander** · Instances: Gate/Expander 1 (ID 150), Gate/Expander 2 (ID 151)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Threhold | Gate | -100–0 | dB | 152 | — |
| 4 | Ratio | Gate | 1–20 | — | 59 | — |
| 1 | Attack | Gate | 1–100 | ms | 127 | — |
| 2 | Hold | Gate | 10–1000 | ms | 127 | — |
| 3 | Release | Gate | 10–1000 | ms | 127 | — |
| 5 | Sidechain Select | Gate | 0–6 | — | 0 | — |
| 6 | Low Cut | Gate | 10–1000 | Hz | 0 | — |
| 7 | High Cut | Gate | 200–20000 | Hz | 254 | — |
| 9 | Level | Gate | -50–13.5 | dB | 200 | 201 |
| 10 | Balance | Gate | -50–50 | — | 127 | 202 |
| 11 | Bypass Mode | Gate | 0–1 | — | 0 | 255 |
| 8 | Mix | Other | -50–-50 | — | 0 | 200 |
| 12 | Bypass | Other | -50–-50 | — | 0 | — |

**Sidechain Select choices** (catalog order): NONE, ROW 1, ROW 2, ROW 3, ROW 4, INPUT 1, INPUT 2.

**Bypass Mode choices** (catalog order): THRU, MUTE.

## GraphicEQ

**GraphicEQ** · Instances: GraphicEQ 1 (ID 102), GraphicEQ 2 (ID 103), GraphicEQ 3 (ID 160), GraphicEQ 4 (ID 161)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | 63 | GEQ | -12–12 | — | 127 | — |
| 1 | 125 | GEQ | -12–12 | — | 127 | — |
| 2 | 250 | GEQ | -12–12 | — | 127 | — |
| 3 | 500 | GEQ | -12–12 | — | 127 | — |
| 4 | 1k | GEQ | -12–12 | — | 127 | — |
| 5 | 2k | GEQ | -12–12 | — | 127 | — |
| 6 | 4k | GEQ | -12–12 | — | 127 | — |
| 7 | 8k | GEQ | -12–12 | — | 127 | — |
| 9 | Level | GEQ | -50–13.5 | dB | 200 | 201 |
| 10 | Balance | GEQ | -50–50 | — | 127 | 202 |
| 11 | Bypass Mode | GEQ | 0–1 | — | 0 | 255 |
| 8 | Mix | Other | 10–10 | Hz | 0 | 200 |
| 12 | Globalmix | Other | 0–0 | — | 0 | — |
| 13 | Spare1 | Other | 0–0 | OUT | 0 | — |
| 14 | Spare2 | Other | 0–0 | ms | 0 | — |
| 15 | Spare3 | Other | 0–0 | — | 0 | — |
| 16 | Bypass | Other | 0–0 | — | 0 | — |

**Bypass Mode choices** (catalog order): THRU, MUTE.

## EffectsLoop

**EffectsLoop** · Instances: Effects Loop (ID 136)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Level 1 | FX Loop | -20–20 | dB | 127 | — |
| 1 | Level 2 | FX Loop | -20–20 | dB | 127 | — |
| 2 | Level 3 | FX Loop | -20–20 | dB | 127 | — |
| 3 | Level 4 | FX Loop | -20–20 | dB | 127 | — |
| 8 | Main | FX Loop | -20–20 | — | 127 | — |
| 4 | Pan 1 | FX Loop | -50–50 | — | 127 | — |
| 5 | Pan 2 | FX Loop | -50–50 | — | 127 | — |
| 6 | Pan 3 | FX Loop | -50–50 | — | 127 | — |
| 7 | Pan 4 | FX Loop | -50–50 | — | 127 | — |
| 9 | Level | FX Loop | -50–13.5 | dB | 200 | 201 |
| 10 | Balance | FX Loop | -50–50 | — | 127 | 202 |
| 11 | Bypass Mode | FX Loop | 0–1 | — | 0 | 255 |
| 12 | Bypass | Other | -12–-12 | dB | 0 | — |

**Bypass Mode choices** (catalog order): THRU, MUTE.

## MegaTap

**MegaTap** · Instances: Megatap Delay (ID 147)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 2 | Time | Megatap | 31–2468 | ms | 204 | — |
| 4 | Number of Taps | Megatap | 1–40 | — | 16 | — |
| 5 | Time Shape | Megatap | 0–5 | — | 1 | — |
| 6 | Time Alpha | Megatap | 0–100 | % | 64 | — |
| 11 | Time Randomize | Megatap | 0–100 | % | 0 | — |
| 1 | Master level | Megatap | 0–100 | % | 254 | 204 |
| 7 | Amplitude shape | Megatap | 0–5 | — | 0 | — |
| 8 | Amplitude Alpha | Megatap | 0–100 | % | 0 | — |
| 9 | Pan Shape | Megatap | 0–5 | — | 5 | — |
| 10 | Pan Alpha | Megatap | 0–100 | % | 64 | — |
| 12 | Mix | Megatap | 0–100 | % | 64 | 200 |
| 13 | Level | Megatap | -50–13.5 | dB | 200 | 201 |
| 14 | Balance | Megatap | -50–50 | — | 127 | 202 |
| 0 | In Gain | Megatap | 0–100 | % | 254 | 203 |
| 15 | Bypassmode | Megatap | 0–4 | — | 0 | 255 |
| 3 | Fine | Other | 2000–2000 | Hz | 198 | — |
| 16 | Globalmix | Other | 0–1 | — | 0 | — |
| 17 | Bypass | Other | 0.1–0.1 | — | 0 | — |

**Number of Taps choices** (catalog order): 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40.

**Time Shape choices** (catalog order): CONSTANT, INCREASING, DECREASING, UP / DOWN, DOWN / UP, SINE.

**Amplitude shape choices** (catalog order): CONSTANT, INCREASING, DECREASING, UP / DOWN, DOWN / UP, SINE.

**Pan Shape choices** (catalog order): CONSTANT, INCREASING, DECREASING, UP / DOWN, DOWN / UP, SINE.

**Bypassmode choices** (catalog order): MIX = 0%, MUTE FX OUT, MUTE OUT, MUTE FX IN, MUTE IN.

**Globalmix choices** (catalog order): OFF, ON.

## Mixer

**Mixer** · Instances: Mixer 1 (ID 137), Mixer 2 (ID 138)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Gain 1 | Mixer | 0–100 | % | 254 | 200 |
| 1 | Gain 2 | Mixer | 0–100 | % | 254 | 201 |
| 2 | Gain 3 | Mixer | 0–100 | % | 254 | 202 |
| 3 | Gain 4 | Mixer | 0–100 | % | 254 | 203 |
| 4 | Balance 1 | Mixer | -50–50 | — | 127 | 204 |
| 5 | Balance 2 | Mixer | -50–50 | — | 127 | 205 |
| 6 | Balance 3 | Mixer | -50–50 | — | 127 | 206 |
| 7 | Balance 4 | Mixer | -50–50 | — | 127 | 207 |
| 8 | Master level | Mixer | -80–0 | dB | 254 | 208 |
| 9 | Output mode | Mixer | 0–1 | — | 0 | — |

**Output mode choices** (catalog order): STEREO, MONO.

## MultibandComp

**MultibandComp** · Instances: Multiband Comp 1 (ID 154), Multiband Comp 2 (ID 155)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 6 | Level 1 | Bands | -20–20 | dB | 165 | — |
| 8 | Mute 1 | Bands | 0–1 | — | 0 | — |
| 0 | Frequency 1 | Bands | 50–500 | Hz | 97 | — |
| 13 | Level 2 | Bands | -20–20 | dB | 165 | — |
| 15 | Mute 2 | Bands | 0–1 | — | 0 | — |
| 1 | Frequency 2 | Bands | 1000–10000 | Hz | 178 | — |
| 20 | Level 3 | Bands | -20–20 | dB | 165 | — |
| 22 | Mute 3 | Bands | 0–1 | — | 0 | — |
| 2 | Thresh 1 | Bands | -80–0 | dB | 159 | — |
| 3 | Ratio 1 | Bands | 1–20 | — | 59 | — |
| 4 | Attack 1 | Bands | 0–10 | — | 127 | — |
| 5 | Release 1 | Bands | 0–10 | — | 127 | — |
| 9 | Thresh 2 | Bands | -80–0 | dB | 159 | — |
| 10 | Ratio 2 | Bands | 1–20 | — | 59 | — |
| 11 | Attack 2 | Bands | 0–10 | — | 127 | — |
| 12 | Release 2 | Bands | 0–10 | — | 127 | — |
| 16 | Thresh 3 | Bands | -80–0 | dB | 159 | — |
| 17 | Ratio 3 | Bands | 1–20 | — | 59 | — |
| 18 | Attack 3 | Bands | 0–10 | — | 127 | — |
| 19 | Release 3 | Bands | 0–10 | — | 127 | — |
| 7 | Detect 1 | Detect/Mix | 0–1 | — | 0 | — |
| 14 | Detect 2 | Detect/Mix | 0–1 | — | 0 | — |
| 24 | Level | Detect/Mix | -50–13.5 | dB | 200 | 201 |
| 25 | Balance | Detect/Mix | -50–50 | — | 127 | 202 |
| 26 | Bypass Mode | Detect/Mix | 0–1 | — | 0 | 255 |
| 21 | Detect3 | Other | 0–1 | — | 0 | — |
| 23 | Mix | Other | 0–100 | % | 254 | 200 |
| 27 | Bypass | Other | 0.1–0.1 | — | 0 | — |

**Mute 1 choices** (catalog order): OFF, MUTE.

**Mute 2 choices** (catalog order): OFF, MUTE.

**Mute 3 choices** (catalog order): OFF, MUTE.

**Detect 1 choices** (catalog order): RMS, PEAK.

**Detect 2 choices** (catalog order): RMS, PEAK.

**Bypass Mode choices** (catalog order): THRU, MUTE.

**Detect3 choices** (catalog order): RMS, PEAK.

## MultiDelay

**MultiDelay** · Instances: Multidelay 1 (ID 114), Multidelay 2 (ID 115)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 35 | Type | Basic | 0–8 | — | 0 | — |
| 40 | Mstr Time | Master/Mix | 0–100 | % | 254 | 204 |
| 45 | Mstr Feedback | Master/Mix | 0–100 | % | 254 | 209 |
| 43 | Mstr Frequency | Master/Mix | 0.316–3.162 | — | 127 | 207 |
| 44 | Mstr Q | Master/Mix | 0.1–10 | — | 0 | 208 |
| 64 | Mstr Rate | Master/Mix | 1–100 | % | 254 | 212 |
| 66 | Mstr Depth | Master/Mix | 0–100 | % | 254 | 213 |
| 41 | Mstr Level | Master/Mix | 0–100 | % | 254 | 205 |
| 42 | Mstr Pan | Master/Mix | -100–100 | % | 254 | 206 |
| 126 | Diffusion time | Master/Mix | 0–100 | % | 0 | — |
| 37 | Diffusion | Master/Mix | 0–100 | % | 254 | — |
| 28 | Mix | Master/Mix | 0–100 | % | 64 | 200 |
| 29 | Level | Master/Mix | -50–13.5 | dB | 200 | 201 |
| 30 | Balance | Master/Mix | -50–50 | — | 127 | 202 |
| 33 | Input Gain | Master/Mix | 0–100 | % | 254 | 203 |
| 31 | Bypass Mode | Master/Mix | 0–4 | — | 0 | 255 |
| 0 | Time 1 | Delays | 10–2000 | ms | 37 | — |
| 4 | Tempo 1 | Delays | 0–29 | — | 3 | — |
| 12 | Feedback 1 | Delays | 0–100 | % | 25 | — |
| 8 | Level 1 | Delays | 0–100 | % | 254 | — |
| 16 | Pan 1 | Delays | -50–50 | — | 64 | — |
| 2 | Time 3 | Delays | 10–2000 | ms | 88 | — |
| 6 | Tempo 3 | Delays | 0–29 | — | 9 | — |
| 14 | Feedback 3 | Delays | 0–100 | % | 25 | — |
| 10 | Level 3 | Delays | 0–100 | % | 254 | — |
| 18 | Pan 3 | Delays | -50–50 | — | 0 | — |
| 1 | Time 2 | Delays | 10–2000 | ms | 63 | — |
| 5 | Tempo 2 | Delays | 0–29 | — | 6 | — |
| 13 | Feedback 2 | Delays | 0–100 | % | 25 | — |
| 9 | Level 2 | Delays | 0–100 | % | 254 | — |
| 17 | Pan 2 | Delays | -50–50 | — | 191 | — |
| 3 | Time 4 | Delays | 10–2000 | ms | 114 | — |
| 7 | Tempo 4 | Delays | 0–29 | — | 8 | — |
| 15 | Feedback 4 | Delays | 0–100 | % | 25 | — |
| 11 | Level 4 | Delays | 0–100 | % | 254 | — |
| 19 | Pan 4 | Delays | -50–50 | — | 254 | — |
| 56 | Freq 1 | Tone/Duck | 100–10000 | Hz | 89 | 214 |
| 60 | Q 1 | Tone/Duck | 0.1–10 | — | 0 | — |
| 58 | Freq 3 | Tone/Duck | 100–10000 | Hz | 89 | 216 |
| 62 | Q 3 | Tone/Duck | 0.1–10 | — | 0 | — |
| 65 | Ducker Attenuation | Tone/Duck | 0–80 | dB | 0 | — |
| 38 | Ducker Threshold | Tone/Duck | -80–0 | dB | 0 | — |
| 125 | Ducker Release | Tone/Duck | 1–1000 | ms | 0 | — |
| 57 | Freq 2 | Tone/Duck | 100–10000 | Hz | 89 | 215 |
| 61 | Q 2 | Tone/Duck | 0.1–10 | — | 0 | — |
| 59 | Freq 4 | Tone/Duck | 100–10000 | Hz | 89 | 217 |
| 63 | Q 4 | Tone/Duck | 0.1–10 | — | 0 | — |
| 73 | LFO1 Master | Modulation | 0–1 | — | 1 | — |
| 20 | LFO1 Rate | Modulation | 0–10 | Hz | 89 | — |
| 24 | LFO1 Tempo | Modulation | 0–29 | — | 0 | — |
| 69 | LFO1 Depth | Modulation | 0–100 | % | 0 | — |
| 22 | LFO3 Rate | Modulation | 0–10 | Hz | 89 | — |
| 26 | LFO3 Tempo | Modulation | 0–29 | — | 0 | — |
| 71 | LFO3 Depth | Modulation | 0–100 | % | 0 | — |
| 21 | LFO2 Rate | Modulation | 0–10 | Hz | 89 | — |
| 25 | LFO2 Tempo | Modulation | 0–29 | — | 0 | — |
| 70 | LFO2 Depth | Modulation | 0–100 | % | 0 | — |
| 23 | LFO4 Rate | Modulation | 0–10 | Hz | 89 | — |
| 27 | LFO4 Tempo | Modulation | 0–29 | — | 0 | — |
| 72 | LFO4 Depth | Modulation | 0–100 | % | 0 | — |
| 36 | Decay time | Master/Mix | 0.01–60 | sec | 21 | — |
| 47 | Master Detune | Master/Mix | -127–127 | % | 227 | 211 |
| 39 | Crossfade | Master/Mix | 0–100 | % | 127 | — |
| 48 | Detune 1 | Dly/Detune | -50–50 | ct | 137 | — |
| 50 | Detune 3 | Dly/Detune | -50–50 | ct | 122 | — |
| 49 | Detune 2 | Dly/Detune | -50–50 | ct | 132 | — |
| 51 | Detune 4 | Dly/Detune | -50–50 | ct | 117 | — |
| 46 | Master Pitch | Master | -127–127 | % | 227 | 210 |
| 67 | Direction | Master | 0–1 | — | 0 | — |
| 52 | Shift 1 | Dlys/Pitch | 103–151 | — | 127 | — |
| 54 | Shift 3 | Dlys/Pitch | 103–151 | — | 127 | — |
| 53 | Shift 2 | Dlys/Pitch | 103–151 | — | 127 | — |
| 55 | Shift 4 | Dlys/Pitch | 103–151 | — | 127 | — |
| 92 | Feedback | Delays | 0–100 | % | 0 | — |
| 74 | FB Send | Delays | 0–3 | — | 3 | — |
| 75 | FB Return | Delays | 0–3 | — | 0 | — |
| 77 | Delay time | Taps | 40–9968 | ms | 12 | — |
| 85 | Delay tempo | Taps | 0–29 | — | 0 | — |
| 83 | Number of Taps | Taps | 1–10 | — | 6 | — |
| 81 | Decay | Taps | 0–100 | % | 127 | — |
| 84 | Shuffle | Taps | 0–50 | % | 0 | — |
| 89 | Low cut | Taps | 20–2000 | Hz | 0 | — |
| 90 | High cut | Taps | 200–20000 | Hz | 254 | — |
| 76 | Mono/Stereo | Taps | 0–1 | — | 0 | — |
| 86 | Spread | Taps | 0–100 | % | 254 | — |
| 91 | Ratio | Taps | 0–100 | % | 254 | — |
| 87 | Pan Shape | Taps | 0–5 | — | 0 | — |
| 88 | Pan alpha | Taps | 0–100 | % | 0 | — |
| 113 | Tap1 Level | Levels | -50–13.5 | dB | 200 | — |
| 115 | Tap3 Level | Levels | -50–13.5 | dB | 200 | — |
| 117 | Tap5 Level | Levels | -50–13.5 | dB | 200 | — |
| 119 | Tap7 Level | Levels | -50–13.5 | dB | 200 | — |
| 121 | Tap9 Level | Levels | -50–13.5 | dB | 200 | — |
| 114 | Tap2 Level | Levels | -50–13.5 | dB | 200 | — |
| 116 | Tap4 Level | Levels | -50–13.5 | dB | 200 | — |
| 118 | Tap6 Level | Levels | -50–13.5 | dB | 200 | — |
| 120 | Tap8 Level | Levels | -50–13.5 | dB | 200 | — |
| 122 | Tap10 Level | Levels | -50–13.5 | dB | 200 | — |
| 80 | Quantize | Taps | 0–29 | — | 0 | — |
| 93 | Tap1 Time | Taps | 31–9968 | ms | 12 | — |
| 95 | Tap2 Time | Taps | 31–9968 | ms | 12 | — |
| 97 | Tap3 Time | Taps | 31–9968 | ms | 12 | — |
| 99 | Tap4 Time | Taps | 31–9968 | ms | 12 | — |
| 101 | Tap5 Time | Taps | 31–9968 | ms | 12 | — |
| 103 | Tap6 Time | Taps | 31–9968 | ms | 12 | — |
| 105 | Tap7 Time | Taps | 31–9968 | ms | 0 | — |
| 107 | Tap8 Time | Taps | 31–9968 | ms | 0 | — |
| 109 | Tap9 Time | Taps | 31–9968 | ms | 0 | — |
| 111 | Tap10 Time | Taps | 31–9968 | ms | 0 | — |
| 32 | Globalmix | Other | 0–1 | — | 0 | — |
| 34 | Bypass | Other | -50–-50 | — | 0 | — |
| 68 | Maxdepth | Other | 0–1 | — | 0 | — |
| 78 | Timel | Other | 0–0 | ms | 25 | — |
| 79 | Subdiv | Other | 0–29 | — | 0 | — |
| 82 | Decaystyle | Other | 0–1 | — | 0 | — |
| 94 | Time1L | Other | 0–0 | — | 204 | — |
| 96 | Time2L | Other | 0–0 | — | 204 | — |
| 98 | Time3L | Other | 0–0 | — | 204 | — |
| 100 | Time4L | Other | 0–0 | — | 204 | — |
| 102 | Time5L | Other | 0–0 | — | 204 | — |
| 104 | Time6L | Other | 0–0 | — | 204 | — |
| 106 | Time7L | Other | 0–0 | — | 0 | — |
| 108 | Time8L | Other | 0–0 | — | 0 | — |
| 110 | Time9L | Other | 0–0 | — | 0 | — |
| 112 | Time10L | Other | 0–0 | — | 0 | — |
| 123 | Reftempo | Other | 30–250 | — | 95 | — |
| 124 | Tracktempo | Other | 0–0 | — | 0 | — |

**Type choices** (catalog order): QUAD-TAP, PLEX DELAY, PLEX DETUNE, PLEX SHIFT, BAND DELAY, QUAD-SERIES, TEN-TAP DLY, RHYTHM TAP, DIFFUSOR.

**Bypass Mode choices** (catalog order): MIX = 0%, MUTE FX OUT, MUTE OUT, MUTE FX IN, MUTE IN.

**Tempo 1 choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**Tempo 3 choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**Tempo 2 choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**Tempo 4 choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**LFO1 Master choices** (catalog order): OFF, ON.

**LFO1 Tempo choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**LFO3 Tempo choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**LFO2 Tempo choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**LFO4 Tempo choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**Direction choices** (catalog order): FORWARD, REVERSE.

**Shift 1 choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**Shift 3 choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**Shift 2 choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**Shift 4 choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**FB Send choices** (catalog order): 1, 2, 3, 4.

**FB Return choices** (catalog order): 1, 2, 3, 4.

**Delay tempo choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**Number of Taps choices** (catalog order): 1, 2, 3, 4, 5, 6, 7, 8, 9, 10.

**Mono/Stereo choices** (catalog order): MONO, STEREO.

**Pan Shape choices** (catalog order): CONSTANT, INCREASING, DECREASING, UP / DOWN, DOWN / UP, SINE.

**Quantize choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**Globalmix choices** (catalog order): OFF, ON.

**Maxdepth choices** (catalog order): 0, 1.

**Subdiv choices** (catalog order): 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29.

**Decaystyle choices** (catalog order): 0, 1.

**Reftempo choices** (catalog order): , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , , .

## ParametricEQ

**ParametricEQ** · Instances: Parametric EQ 1 (ID 104), Parametric EQ 2 (ID 105), Parametric EQ 3 (ID 162), Parametric EQ 4 (ID 163)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Freq 1 | Bands 1+5 | 20–2000 | Hz | 127 | — |
| 5 | Q1 | Bands 1+5 | 0.1–5 | — | 127 | — |
| 10 | Gain 1 | Bands 1+5 | -12–12 | dB | 127 | — |
| 4 | Freq 5 | Bands 1+5 | 200–20000 | Hz | 153 | — |
| 9 | Q5 | Bands 1+5 | 0.1–5 | — | 127 | — |
| 14 | Gain 5 | Bands 1+5 | -12–12 | dB | 127 | — |
| 20 | Frequency 1 Type | Bands 1+5 | 0–2 | — | 0 | — |
| 21 | Frequency 5 Type | Bands 1+5 | 0–2 | — | 0 | — |
| 16 | Level | Bands 1+5 | -50–13.5 | dB | 200 | 201 |
| 17 | Balance | Bands 1+5 | -50–50 | — | 127 | 202 |
| 18 | Bypass Mode | Bands 1+5 | 0–1 | — | 0 | 255 |
| 1 | Freq 2 | Bands 2,3,4 | 100–10000 | Hz | 76 | — |
| 6 | Q2 | Bands 2,3,4 | 0.1–5 | — | 127 | — |
| 11 | Gain 2 | Bands 2,3,4 | -12–12 | dB | 127 | — |
| 3 | Freq 4 | Bands 2,3,4 | 100–10000 | Hz | 153 | — |
| 8 | Q4 | Bands 2,3,4 | 0.1–5 | — | 127 | — |
| 13 | Gain 4 | Bands 2,3,4 | -12–12 | dB | 127 | — |
| 2 | Freq 3 | Bands 2,3,4 | 100–10000 | Hz | 115 | — |
| 7 | Q3 | Bands 2,3,4 | 0.1–5 | — | 127 | — |
| 12 | Gain 3 | Bands 2,3,4 | -12–12 | dB | 127 | — |
| 15 | Mix | Other | 0–0 | — | 0 | 200 |
| 19 | Globalmix | Other | 0–1 | — | 0 | — |
| 22 | Spare3 | Other | 1–1 | — | 0 | — |
| 23 | Bypass | Other | 1–1 | — | 0 | — |

**Frequency 1 Type choices** (catalog order): SHELVING, PEAKING, BLOCKING.

**Frequency 5 Type choices** (catalog order): SHELVING, PEAKING, BLOCKING.

**Bypass Mode choices** (catalog order): THRU, MUTE.

**Globalmix choices** (catalog order): OFF, ON.

## Phaser

**Phaser** · Instances: Phaser 1 (ID 122), Phaser 2 (ID 123)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Rate | Phaser | 0–10 | Hz | 128 | 203 |
| 3 | Tempo | Phaser | 0–29 | — | 0 | — |
| 2 | LFO Type | Phaser | 0–8 | — | 1 | — |
| 8 | LFO Phase | Phaser | 0–180 | deg | 0 | — |
| 4 | Depth | Phaser | 0–10 | — | 130 | 204 |
| 5 | Resonance | Phaser | -100–100 | % | 127 | 205 |
| 0 | Order | Phaser | 1–7 | — | 2 | — |
| 6 | Frequency Start | Phaser | 100–1000 | Hz | 121 | 206 |
| 7 | Frequency Span | Phaser | 1–10 | — | 0 | — |
| 15 | Bulb Bias | Phaser | 0.5–10 | — | 94 | — |
| 9 | Mix | Phaser | 0–100 | % | 127 | 200 |
| 10 | Level | Phaser | -50–13.5 | dB | 200 | 201 |
| 11 | Balance | Phaser | -50–50 | — | 127 | 202 |
| 12 | Bypass Mode | Phaser | 0–2 | — | 0 | 255 |
| 13 | Globalmix | Other | 0–1 | — | 0 | — |
| 14 | Bypass | Other | 0–0 | % | 0 | — |

**Tempo choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**LFO Type choices** (catalog order): SINE, TRIANGLE, SQUARE, SAW UP, SAW DOWN, RANDOM, LOG, EXP, TRAPEZOID.

**Order choices** (catalog order): 2, 4, 6, 8, 10, 12, VIBE (4).

**Bypass Mode choices** (catalog order): MIX = 0%, MUTE FX OUT, MUTE OUT.

**Globalmix choices** (catalog order): OFF, ON.

## Pitch

**Pitch** · Instances: Pitch 1 (ID 130), Pitch 2 (ID 153)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Type | Basic | 0–9 | — | 0 | — |
| 8 | Voice1 Detune | Detune | -50–50 | ct | 127 | 204 |
| 12 | Level 1 | Detune | -80–0 | dB | 254 | — |
| 14 | Pan 1 | Detune | -50–50 | — | 127 | — |
| 78 | Delay 1 | Detune | 0–254 | ms | 0 | — |
| 80 | Pitch Source | Detune | 0–2 | — | 0 | — |
| 38 | Hi Cut Frequency | Detune | 2000–20000 | Hz | 178 | — |
| 9 | Voice2 Detune | Detune | -50–50 | ct | 127 | 205 |
| 13 | Level 2 | Detune | -80–0 | dB | 254 | — |
| 15 | Pan 2 | Detune | -50–50 | — | 127 | — |
| 79 | Delay 2 | Detune | 0–254 | ms | 0 | — |
| 22 | Mix | Detune | 0–100 | % | 64 | 200 |
| 23 | Level | Detune | -50–13.5 | dB | 200 | 201 |
| 24 | Balance | Detune | -50–50 | — | 127 | 202 |
| 27 | Input Gain | Detune | 0–100 | % | 254 | 206 |
| 25 | Bypass Mode | Detune | 0–4 | — | 0 | 255 |
| 10 | Voice1 Shift | Voices | 103–151 | — | 127 | — |
| 16 | Delay 1 | Voices | 0–2000 | ms | 0 | — |
| 32 | Delay Tempo 1 | Voices | 0–29 | — | 0 | — |
| 18 | Feedback 1 | Voices | 0–100 | % | 0 | — |
| 11 | Voice2 Shift | Voices | 103–151 | — | 127 | — |
| 17 | Delay 2 | Voices | 0–2000 | ms | 0 | — |
| 33 | Delay Tempo 2 | Voices | 0–29 | — | 0 | — |
| 19 | Feedback 2 | Voices | 0–100 | % | 0 | — |
| 2 | Master Pitch | Mstr/Track | 0–100 | % | 254 | 203 |
| 40 | Master Delay | Mstr/Track | 0–100 | % | 254 | 207 |
| 41 | Master Fdbk | Mstr/Track | 0–100 | % | 254 | 208 |
| 43 | Master Level | Mstr/Track | 0–100 | % | 254 | 210 |
| 42 | Master Pan | Mstr/Track | -100–100 | % | 254 | 209 |
| 20 | Pitch Track | Mstr/Track | 0–1 | — | 1 | — |
| 21 | Track Adjust | Mstr/Track | 0–10 | — | 143 | — |
| 3 | Voice1 Harmony | Voices | 113–141 | — | 127 | — |
| 4 | Voice2 Harmony | Voices | 113–141 | — | 127 | — |
| 7 | Track Mode | Mstr/Track | 0–1 | — | 0 | — |
| 39 | Glide Time | Mstr/Track | 1–1000 | ms | 0 | — |
| 5 | Key | Key/Scale | 0–11 | — | 0 | — |
| 6 | Scale | Key/Scale | 0–17 | — | 0 | — |
| 44 | Custom Notes | Key/Scale | 4–8 | — | 7 | — |
| 81 | Tonic | Key/Scale | 0–11 | — | 0 | — |
| 45 | Note 2 | Key/Scale | 0–11 | — | 0 | — |
| 46 | Note 3 | Key/Scale | 0–11 | — | 1 | — |
| 47 | Note 4 | Key/Scale | 0–11 | — | 2 | — |
| 48 | Note 5 | Key/Scale | 0–11 | — | 3 | — |
| 49 | Note 6 | Key/Scale | 0–11 | — | 4 | — |
| 50 | Note 7 | Key/Scale | 0–11 | — | 5 | — |
| 51 | Note 8 | Key/Scale | 0–11 | — | 6 | — |
| 1 | Mode | Whammy | 0–5 | — | 0 | — |
| 30 | V1 Splice | Splice | 1–2000 | ms | 63 | — |
| 34 | Spltempo 1 | Splice | 0–29 | — | 0 | — |
| 29 | Crossfade | Splice | 0–100 | % | 127 | — |
| 28 | Reverse | Splice | 0–0 | % | 2 | — |
| 31 | V2 Splice | Splice | 1–2000 | ms | 63 | — |
| 35 | Spltempo 2 | Splice | 0–29 | — | 0 | — |
| 36 | Feedback type | Master | 0–2 | — | 0 | — |
| 56 | Run | Sequencer | 0–1 | — | 1 | 211 |
| 57 | Tempo | Sequencer | 1–29 | — | 6 | — |
| 54 | Stages | Sequencer | 2–16 | — | 4 | — |
| 58 |   Stage 1   Shift | Sequencer | 103–151 | — | 127 | — |
| 59 |   Stage 2   Shift | Sequencer | 103–151 | — | 129 | — |
| 60 |   Stage 3   Shift | Sequencer | 103–151 | — | 131 | — |
| 61 |   Stage 4   Shift | Sequencer | 103–151 | — | 134 | — |
| 62 |   Stage 5   Shift | Sequencer | 103–151 | — | 127 | — |
| 63 |   Stage 6   Shift | Sequencer | 103–151 | — | 127 | — |
| 64 |   Stage 7   Shift | Sequencer | 103–151 | — | 127 | — |
| 65 |   Stage 8   Shift | Sequencer | 103–151 | — | 127 | — |
| 55 | Repeats | Sequencer | 1–31 | — | 31 | — |
| 66 |   Stage 9   Shift | Sequencer | 103–151 | — | 127 | — |
| 67 |   Stage 10  Shift | Sequencer | 103–151 | — | 127 | — |
| 68 |   Stage 11  Shift | Sequencer | 103–151 | — | 127 | — |
| 69 |   Stage 12  Shift | Sequencer | 103–151 | — | 127 | — |
| 70 |   Stage 13  Shift | Sequencer | 103–151 | — | 127 | — |
| 71 |   Stage 14  Shift | Sequencer | 103–151 | — | 127 | — |
| 72 |   Stage 15  Shift | Sequencer | 103–151 | — | 127 | — |
| 73 |   Stage 16  Shift | Sequencer | 103–151 | — | 127 | — |
| 74 | Amplitude Shape | Mstr/More | 0–5 | — | 0 | — |
| 75 | Amplitude Alpha | Mstr/More | 0–100 | % | 0 | — |
| 76 | Pan Shape | Mstr/More | 0–5 | — | 0 | — |
| 77 | Pan Alpha | Mstr/More | 0–100 | % | 0 | — |
| 52 | Voice 1 Scale | Voices | 0–31 | — | 0 | — |
| 53 | Voice 2 Scale | Voices | 0–31 | — | 0 | — |
| 26 | Globalmix | Other | 0–1 | — | 0 | — |
| 37 | Direction | Other | 0–0 | — | 0 | — |

**Type choices** (catalog order): DETUNE, FIXED HARM, INTEL HARM, CL. WHAMMY, OCTAVE DIV, CRYSTALS, AD. WHAMMY, ARPEGGIATOR, CUST. SHIFT, AUTO PITCH.

**Pitch Source choices** (catalog order): GLOBAL, LOCAL MONO, LOCAL POLY.

**Bypass Mode choices** (catalog order): MIX = 0%, MUTE FX OUT, MUTE OUT, MUTE FX IN, MUTE IN.

**Voice1 Shift choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**Delay Tempo 1 choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**Voice2 Shift choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**Delay Tempo 2 choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**Pitch Track choices** (catalog order): OFF, ON.

**Voice1 Harmony choices** (catalog order): -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15.

**Voice2 Harmony choices** (catalog order): -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15.

**Track Mode choices** (catalog order): SMOOTH, STEPPED.

**Key choices** (catalog order): A, Bb, B, C, Db, D, Eb, E, F, Gb, G, Ab.

**Scale choices** (catalog order): IONIAN MAJ, DORIAN, PHRYGIAN, LYDIAN, MIXOLYDIAN, AEOLIAN MIN, LOCRIAN, MEL. MINOR, HARM. MINOR, DIMINISHED, WHOLE TONE, DOM. SEVEN, DIM. WHOLE, PENTA. MAJ, PENTA. MIN, BLUES, CHROMATIC, CUSTOM.

**Custom Notes choices** (catalog order): 4, 5, 6, 7, 8.

**Tonic choices** (catalog order): C, C#, D, D#, E, F, F#, G, G#, A, A#, B.

**Note 2 choices** (catalog order): C, C#, D, D#, E, F, F#, G, G#, A, A#, B.

**Note 3 choices** (catalog order): C, C#, D, D#, E, F, F#, G, G#, A, A#, B.

**Note 4 choices** (catalog order): C, C#, D, D#, E, F, F#, G, G#, A, A#, B.

**Note 5 choices** (catalog order): C, C#, D, D#, E, F, F#, G, G#, A, A#, B.

**Note 6 choices** (catalog order): C, C#, D, D#, E, F, F#, G, G#, A, A#, B.

**Note 7 choices** (catalog order): C, C#, D, D#, E, F, F#, G, G#, A, A#, B.

**Note 8 choices** (catalog order): C, C#, D, D#, E, F, F#, G, G#, A, A#, B.

**Mode choices** (catalog order): UP 1 OCT, DOWN 1 OCT, UP 2 OCT, DOWN 2 OCT, UP/DN 1 OCT, UP/DN 2 OCT.

**Spltempo 1 choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**Spltempo 2 choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**Feedback type choices** (catalog order): DUAL, BOTH, PING-PONG.

**Run choices** (catalog order): OFF, ON.

**Tempo choices** (catalog order): 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**Stages choices** (catalog order): 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16.

**  Stage 1   Shift choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**  Stage 2   Shift choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**  Stage 3   Shift choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**  Stage 4   Shift choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**  Stage 5   Shift choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**  Stage 6   Shift choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**  Stage 7   Shift choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**  Stage 8   Shift choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**Repeats choices** (catalog order): 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, INFINITE.

**  Stage 9   Shift choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**  Stage 10  Shift choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**  Stage 11  Shift choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**  Stage 12  Shift choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**  Stage 13  Shift choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**  Stage 14  Shift choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**  Stage 15  Shift choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**  Stage 16  Shift choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**Amplitude Shape choices** (catalog order): CONSTANT, INCREASING, DECREASING, UP / DOWN, DOWN / UP, SINE.

**Pan Shape choices** (catalog order): CONSTANT, INCREASING, DECREASING, UP / DOWN, DOWN / UP, SINE.

**Voice 1 Scale choices** (catalog order): 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32.

**Voice 2 Scale choices** (catalog order): 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32.

**Globalmix choices** (catalog order): OFF, ON.

## QuadChorus

**QuadChorus** · Instances: Quad Chorus 1 (ID 156), Quad Chorus 2 (ID 157)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 3 | Mstr Rate | Master | 0.1–10 | Hz | 127 | 206 |
| 4 | Mstr Depth | Master | 0–100 | % | 64 | 207 |
| 5 | Feedback | Master | 0–100 | % | 0 | 208 |
| 0 | Mstr Time | Master | 0–100 | % | 127 | 203 |
| 1 | Mstr Level | Master | 0–100 | % | 254 | 204 |
| 2 | Mstr Pan | Master | -100–100 | % | 254 | 205 |
| 35 | Input Mode | Master | 0–1 | — | 1 | — |
| 37 | Wide Mode | Master | 0–1 | — | 1 | — |
| 45 | Hicut Frequency | Master | 200–20000 | Hz | 254 | — |
| 34 | Main Depth (LFO4>ALL) | Master | 0–100 | % | 64 | — |
| 38 | Main Phase (LFO4) | Master | 0–180 | deg | 0 | — |
| 39 | Mix | Master | 0–100 | % | 64 | 200 |
| 40 | Level | Master | -50–13.5 | dB | 200 | 201 |
| 41 | Balance | Master | -50–50 | — | 127 | 202 |
| 42 | Bypass Mode | Master | 0–4 | — | 0 | 255 |
| 30 | LFO1 Rate Multiplier | Units 1+2 | 0.1–10 | — | 127 | — |
| 26 | LFO1 Type | Units 1+2 | 0–8 | — | 0 | — |
| 10 | Level 1 | Units 1+2 | 0–100 | % | 254 | — |
| 36 | LFO1 Master | Units 1+2 | 0–1 | — | 0 | — |
| 31 | LFO2 Rate Multiplier | Units 1+2 | 0.1–10 | — | 121 | — |
| 27 | LFO2 Type | Units 1+2 | 0–8 | — | 1 | — |
| 11 | Level 2 | Units 1+2 | 0–100 | % | 254 | — |
| 6 | Time 1 | Units 1+2 | 1–50 | ms | 47 | — |
| 18 | Depth 1 | Units 1+2 | 0–100 | % | 127 | — |
| 22 | Morph1 (LFO1/2/3) | Units 1+2 | 0–100 | % | 0 | — |
| 14 | Pan 1 | Units 1+2 | -50–50 | — | 0 | — |
| 7 | Time 2 | Units 1+2 | 1–50 | ms | 98 | — |
| 19 | Depth 2 | Units 1+2 | 0–100 | % | 127 | — |
| 23 | Morph2 (LFO1/2/3) | Units 1+2 | 0–100 | % | 51 | — |
| 15 | Pan 2 | Units 1+2 | -50–50 | — | 85 | — |
| 32 | LFO3 Rate Multiplier | Units 3+4 | 0.1–10 | — | 127 | — |
| 28 | LFO3 Type | Units 3+4 | 0–8 | — | 6 | — |
| 12 | Level 3 | Units 3+4 | 0–100 | % | 254 | — |
| 33 | LFO4 Rate Multiplier | Units 3+4 | 0.1–10 | — | 132 | — |
| 29 | LFO4 Type | Units 3+4 | 0–8 | — | 0 | — |
| 13 | Level 4 | Units 3+4 | 0–100 | % | 254 | — |
| 8 | Time 3 | Units 3+4 | 1–50 | ms | 150 | — |
| 20 | Depth 3 | Units 3+4 | 0–100 | % | 127 | — |
| 24 | Morph3 (LFO1/2/3) | Units 3+4 | 0–100 | % | 102 | — |
| 16 | Pan 3 | Units 3+4 | -50–50 | — | 169 | — |
| 9 | Time 4 | Units 3+4 | 1–50 | ms | 202 | — |
| 21 | Depth 4 | Units 3+4 | 0–100 | % | 127 | — |
| 25 | Morph4 (LFO1/2/3) | Units 3+4 | 0–100 | % | 152 | — |
| 17 | Pan 4 | Units 3+4 | -50–50 | — | 254 | — |
| 43 | Globalmix | Other | 0–1 | — | 0 | — |
| 44 | Bypass | Other | -1–-1 | — | 0 | — |

**Input Mode choices** (catalog order): MONO, STEREO.

**Wide Mode choices** (catalog order): OFF, ON.

**Bypass Mode choices** (catalog order): MIX = 0%, MUTE FX OUT, MUTE OUT, MUTE FX IN, MUTE IN.

**LFO1 Type choices** (catalog order): SINE, TRIANGLE, SQUARE, SAW UP, SAW DOWN, RANDOM, LOG, EXP, TRAPEZOID.

**LFO1 Master choices** (catalog order): OFF, ON.

**LFO2 Type choices** (catalog order): SINE, TRIANGLE, SQUARE, SAW UP, SAW DOWN, RANDOM, LOG, EXP, TRAPEZOID.

**LFO3 Type choices** (catalog order): SINE, TRIANGLE, SQUARE, SAW UP, SAW DOWN, RANDOM, LOG, EXP, TRAPEZOID.

**LFO4 Type choices** (catalog order): SINE, TRIANGLE, SQUARE, SAW UP, SAW DOWN, RANDOM, LOG, EXP, TRAPEZOID.

**Globalmix choices** (catalog order): OFF, ON.

## Resonator

**Resonator** · Instances: Resonator 1 (ID 158), Resonator 2 (ID 159)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Type | Basic | 0–1 | — | 0 | — |
| 9 | Freq  1 | Filter | 100–10000 | — | 38 | — |
| 21 | Q 1 | Filter | 0.1–10 | — | 0 | — |
| 17 | Filter Loc 1 | Filter | 0–1 | — | 0 | — |
| 10 | Freq  2 | Filter | 100–10000 | — | 61 | — |
| 22 | Q 2 | Filter | 0.1–10 | — | 0 | — |
| 18 | Filter Loc 2 | Filter | 0–1 | — | 0 | — |
| 11 | Freq  3 | Filter | 100–10000 | — | 76 | — |
| 23 | Q 3 | Filter | 0.1–10 | — | 0 | — |
| 19 | Filter Loc 3 | Filter | 0–1 | — | 0 | — |
| 12 | Freq  4 | Filter | 100–10000 | — | 99 | — |
| 24 | Q 4 | Filter | 0.1–10 | — | 0 | — |
| 20 | Filter Loc 4 | Filter | 0–1 | — | 0 | — |
| 13 | FB 1 | Filter | -100–100 | % | 25 | — |
| 25 | Level 1 | Filter | 0–100 | % | 254 | — |
| 29 | Pan 1 | Filter | -50–50 | — | 0 | — |
| 14 | FB 2 | Filter | -100–100 | % | 25 | — |
| 26 | Level 2 | Filter | 0–100 | % | 254 | — |
| 30 | Pan 2 | Filter | -50–50 | — | 64 | — |
| 15 | FB 3 | Filter | -100–100 | % | 25 | — |
| 27 | Level 3 | Filter | 0–100 | % | 254 | — |
| 31 | Pan 3 | Filter | -50–50 | — | 191 | — |
| 16 | FB 4 | Filter | -100–100 | % | 25 | — |
| 28 | Level 4 | Filter | 0–100 | % | 254 | — |
| 32 | Pan 4 | Filter | -50–50 | — | 254 | — |
| 4 | Master Frequency | Master/Mix | 0.5–2 | — | 127 | 205 |
| 5 | Master Level | Master/Mix | 0–100 | % | 254 | 206 |
| 6 | Master Pan | Master/Mix | -100–100 | % | 254 | 207 |
| 7 | Master Fdbk | Master/Mix | -100–100 | % | 254 | 208 |
| 8 | Master Q | Master/Mix | 0.1–10 | — | 127 | 209 |
| 39 | Input Mode | Master/Mix | 0–1 | — | 0 | — |
| 33 | Mix | Master/Mix | 0–100 | % | 127 | 200 |
| 34 | Level | Master/Mix | -50–13.5 | dB | 200 | 201 |
| 35 | Balance | Master/Mix | -50–50 | — | 127 | 202 |
| 2 | Input Gain | Master/Mix | 0–100 | % | 254 | 203 |
| 36 | Bypassmode | Master/Mix | 0–4 | — | 0 | 255 |
| 3 | Frequency | Master/Mix | 50–2000 | — | 95 | 204 |
| 1 | Chord Type | Master/Mix | 0–8 | — | 0 | — |
| 37 | Globalmix | Other | 0–1 | — | 0 | — |
| 38 | Bypass | Other | 0–0 | deg | 0 | — |

**Type choices** (catalog order): MANUAL, CHORDAL.

**Filter Loc 1 choices** (catalog order): PRE, POST.

**Filter Loc 2 choices** (catalog order): PRE, POST.

**Filter Loc 3 choices** (catalog order): PRE, POST.

**Filter Loc 4 choices** (catalog order): PRE, POST.

**Input Mode choices** (catalog order): MONO, STEREO.

**Bypassmode choices** (catalog order): MIX = 0%, MUTE FX OUT, MUTE OUT, MUTE FX IN, MUTE IN.

**Chord Type choices** (catalog order): MAJOR, MAJOR 6, DOM. 7, MAJOR 7, MINOR, MINOR 6, MINOR 7, DIMIN., AUGMEN..

**Globalmix choices** (catalog order): OFF, ON.

## Reverb

**Reverb** · Instances: Reverb 1 (ID 110), Reverb 2 (ID 111)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Type | Basic | 0–17 | — | 1 | — |
| 1 | Time | Basic | 0.1–20 | sec | 43 | 203 |
| 5 | Size | Basic | 1–100 | — | 100 | — |
| 3 | Color | Basic | 0–10 | — | 198 | — |
| 10 | Low Cut | Basic | 20–2000 | Hz | 0 | — |
| 2 | High Cut | Basic | 200–20000 | Hz | 178 | — |
| 13 | Mix | Basic | 0–100 | % | 51 | 200 |
| 14 | Level | Basic | -50–13.5 | dB | 200 | 201 |
| 15 | Balance | Basic | -50–50 | — | 127 | 202 |
| 18 | Input Gain | Basic | 0–100 | % | 254 | 204 |
| 16 | Bypass Mode | Basic | 0–4 | — | 0 | 255 |
| 20 | Input Diffusion | Advanced | 0–100 | % | 127 | — |
| 21 | Diffusion Time | Advanced | 0–100 | % | 127 | — |
| 4 | Wall Diffusion | Advanced | 0–100 | % | 0 | — |
| 19 | Echo Density | Advanced | 2–8 | — | 2 | — |
| 23 | Number Springs | Advanced | 2–4 | — | 4 | — |
| 24 | Spring Tone | Advanced | 0–10 | — | 64 | — |
| 9 | PreDelay | Advanced | 0–250 | ms | 0 | — |
| 6 | Tail Delay | Advanced | 0–250 | ms | 0 | — |
| 7 | Early Level | Advanced | -40–10 | dB | 0 | — |
| 8 | Reverb Level | Advanced | -40–10 | dB | 188 | — |
| 11 | Mod Depth | Advanced | 0–100 | % | 0 | — |
| 12 | Mod Rate | Advanced | 0.1–10 | Hz | 127 | — |
| 17 | Globalmix | Other | 0–1 | — | 0 | — |
| 22 | Bypass | Other | -50–-50 | — | 0 | — |

**Type choices** (catalog order): SM ROOM, MD ROOM, LG ROOM, SM HALL, MD HALL, LG HALL, SM CHAMBER, MD CHAMBER, LG CHAMBER, SM PLATE, MD PLATE, LG PLATE, SM CATHEDRAL, MD CATHEDRAL, LG CATHEDRAL, SM SPRING, MD SPRING, LG SPRING.

**Bypass Mode choices** (catalog order): MIX = 0%, MUTE FX OUT, MUTE OUT, MUTE FX IN, MUTE IN.

**Echo Density choices** (catalog order): 2, 3, 4, 5, 6, 7, 8.

**Number Springs choices** (catalog order): 2, 3, 4.

**Globalmix choices** (catalog order): OFF, ON.

## RingMod

**RingMod** · Instances: RingMod (ID 152)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Frequency | Ring Mod | 2–2000 | Hz | 169 | 203 |
| 1 | Frequency multiplier | Ring Mod | 0.5–2 | — | 127 | 204 |
| 2 | Track | Ring Mod | 0–1 | — | 0 | — |
| 3 | Low Cut | Ring Mod | 200–20000 | Hz | 254 | — |
| 4 | Mix | Ring Mod | 0–100 | % | 127 | 200 |
| 5 | Level | Ring Mod | -50–13.5 | dB | 200 | 201 |
| 6 | Balance | Ring Mod | -50–50 | — | 127 | 202 |
| 8 | Global Mix | Ring Mod | 0–1 | — | 0 | — |
| 7 | Bypass Mode | Ring Mod | 0–2 | — | 0 | 255 |
| 9 | Bypass | Other | -50–-50 | dB | 0 | — |

**Track choices** (catalog order): OFF, ON.

**Global Mix choices** (catalog order): OFF, ON.

**Bypass Mode choices** (catalog order): MIX = 0%, MUTE FX OUT, MUTE OUT.

## Rotary

**Rotary** · Instances: Rotary 1 (ID 120), Rotary 2 (ID 121)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Rate | Rotary | 0–10 | Hz | 165 | 203 |
| 4 | Tempo | Rotary | 0–29 | — | 0 | — |
| 1 | Low Rotor Depth | Rotary | 0–100 | % | 127 | — |
| 2 | Hi Rotor Depth | Rotary | 0–100 | % | 127 | — |
| 3 | Hi Rotor Level | Rotary | -6–6 | dB | 127 | — |
| 10 | Hi Rotor Horn Length | Rotary | 0–100 | % | 127 | — |
| 5 | Mix | Rotary | 0–100 | % | 254 | 200 |
| 6 | Level | Rotary | -50–13.5 | dB | 200 | 201 |
| 7 | Balance | Rotary | -50–50 | — | 127 | 202 |
| 8 | Bypass Mode | Rotary | 0–2 | — | 0 | 255 |
| 9 | Globalmix | Other | 0–1 | — | 0 | — |
| 11 | Bypass | Other | 0–0 | — | 0 | — |

**Tempo choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**Bypass Mode choices** (catalog order): MIX = 0%, MUTE FX OUT, MUTE OUT.

**Globalmix choices** (catalog order): OFF, ON.

## Synth

**Synth** · Instances: Synth 1 (ID 144), Synth 2 (ID 145)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Type | Voice 1 | 0–6 | — | 1 | — |
| 2 | Track | Voice 1 | 0–3 | — | 2 | — |
| 6 | Voice 1  Level | Voice 1 | 0–100 | % | 254 | 205 |
| 7 | Voice 1    Pan | Voice 1 | -50–50 | — | 127 | 206 |
| 1 | Frequency | Voice 1 | 20–2000 | Hz | 178 | 203 |
| 3 | Shift | Voice 1 | 103–151 | — | 127 | 213 |
| 4 | Tune | Voice 1 | -50–50 | ct | 127 | 215 |
| 5 | Duty | Voice 1 | 1–99 | % | 127 | 204 |
| 9 | Filter | Voice 1 | 200–20000 | Hz | 216 | 207 |
| 10 | Q | Voice 1 | 0.5–10 | — | 59 | — |
| 8 | Attack | Voice 1 | 5–1000 | ms | 33 | — |
| 23 | Mix | Voice 1 | 0–100 | % | 254 | 200 |
| 24 | Level | Voice 1 | -50–13.5 | dB | 200 | 201 |
| 25 | Pan | Voice 1 | -50–50 | — | 127 | 202 |
| 26 | Bypass Mode | Voice 1 | 0–2 | — | 0 | 255 |
| 11 | Type | Voice 2 | 0–6 | — | 1 | — |
| 13 | Track | Voice 2 | 0–3 | — | 2 | — |
| 17 | Voice 2  Level | Voice 2 | 0–100 | % | 254 | 210 |
| 18 | Voice 2    Pan | Voice 2 | -50–50 | — | 127 | 211 |
| 12 | Frequency | Voice 2 | 20–2000 | Hz | 178 | 208 |
| 14 | Shift | Voice 2 | 103–151 | — | 127 | 214 |
| 15 | Tune | Voice 2 | -50–50 | ct | 127 | 216 |
| 16 | Duty | Voice 2 | 1–99 | % | 127 | 209 |
| 20 | Filter | Voice 2 | 200–20000 | Hz | 216 | 212 |
| 21 | Q | Voice 2 | 0.5–10 | — | 59 | — |
| 19 | Attack | Voice 2 | 5–1000 | ms | 33 | — |
| 22 | Spare1 | Other | 1–1 | ms | 0 | — |
| 27 | Globalmix | Other | 0–1 | — | 0 | — |
| 28 | Bypass | Other | 1–1 | ms | 0 | — |

**Type choices** (catalog order): SINE, TRIANGLE, SQUARE, SAWTOOTH, RANDOM, WHT NOISE, PINK NOISE.

**Track choices** (catalog order): OFF, ENV ONLY, PITCH+ENV, QUANTIZE.

**Shift choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**Bypass Mode choices** (catalog order): MIX = 0%, MUTE FX OUT, MUTE OUT.

**Type choices** (catalog order): SINE, TRIANGLE, SQUARE, SAWTOOTH, RANDOM, WHT NOISE, PINK NOISE.

**Track choices** (catalog order): OFF, ENV ONLY, PITCH+ENV, QUANTIZE.

**Shift choices** (catalog order): -24, -23, -22, -21, -20, -19, -18, -17, -16, -15, -14, -13, -12, -11, -10, -9, -8, -7, -6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24.

**Globalmix choices** (catalog order): OFF, ON.

## Vocoder

**Vocoder** · Instances: Vocoder (ID 146)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Input Select (Carrier) | Vocoder | 0–1 | — | 0 | — |
| 1 | Bands | Vocoder | 0–3 | — | 3 | — |
| 2 | Frequency Min | Vocoder | 20–2000 | Hz | 127 | — |
| 3 | Frequency Max  | Vocoder | 2000–20000 | Hz | 101 | — |
| 8 | Resonance | Vocoder | 0.2–5 | — | 127 | — |
| 4 | Shift | Vocoder | 0.5–2 | — | 127 | — |
| 11 | Highpass Mix In | Vocoder | 0–100 | % | 0 | — |
| 9 | Attack | Vocoder | 5–1000 | ms | 0 | — |
| 10 | Release | Vocoder | 5–1000 | ms | 0 | — |
| 5 | Freeze | Vocoder | 0–1 | — | 0 | 205 |
| 12 | Mix | Vocoder | 0–100 | % | 254 | 200 |
| 13 | Level | Vocoder | -50–13.5 | dB | 200 | 201 |
| 14 | Balance | Vocoder | -50–50 | — | 127 | 202 |
| 15 | Bypass Mode | Vocoder | 0–2 | — | 0 | 255 |
| 6 | Master Level | Level | 0–100 | % | 254 | 203 |
| 17 | 1 | Level | 0–100 | % | 127 | — |
| 18 | 2 | Level | 0–100 | % | 127 | — |
| 19 | 3 | Level | 0–100 | % | 127 | — |
| 20 | 4 | Level | 0–100 | % | 127 | — |
| 21 | 5 | Level | 0–100 | % | 127 | — |
| 22 | 6 | Level | 0–100 | % | 127 | — |
| 23 | 7 | Level | 0–100 | % | 127 | — |
| 24 | 8 | Level | 0–100 | % | 127 | — |
| 25 | 9 | Level | 0–100 | % | 127 | — |
| 26 | 10 | Level | 0–100 | % | 127 | — |
| 27 | 11 | Level | 0–100 | % | 127 | — |
| 28 | 12 | Level | 0–100 | % | 127 | — |
| 29 | 13 | Level | 0–100 | % | 127 | — |
| 30 | 14 | Level | 0–100 | % | 127 | — |
| 31 | 15 | Level | 0–100 | % | 127 | — |
| 32 | 16 | Level | 0–100 | % | 127 | — |
| 7 | Master Pan | Pan | -100–100 | % | 254 | 204 |
| 33 | Pan 1 | Pan | -50–50 | — | 127 | — |
| 35 | Pan 3 | Pan | -50–50 | — | 127 | — |
| 37 | Pan 5 | Pan | -50–50 | — | 127 | — |
| 39 | Pan 7 | Pan | -50–50 | — | 127 | — |
| 41 | Pan 9 | Pan | -50–50 | — | 127 | — |
| 43 | Pan 11 | Pan | -50–50 | — | 127 | — |
| 45 | Pan 13 | Pan | -50–50 | — | 127 | — |
| 47 | Pan 15 | Pan | -50–50 | — | 127 | — |
| 34 | Pan 2 | Pan | -50–50 | — | 127 | — |
| 36 | Pan 4 | Pan | -50–50 | — | 127 | — |
| 38 | Pan 6 | Pan | -50–50 | — | 127 | — |
| 40 | Pan 8 | Pan | -50–50 | — | 127 | — |
| 42 | Pan 10 | Pan | -50–50 | — | 127 | — |
| 44 | Pan 12 | Pan | -50–50 | — | 127 | — |
| 46 | Pan 14 | Pan | -50–50 | — | 127 | — |
| 48 | Pan 16 | Pan | -50–50 | — | 127 | — |
| 16 | Globalmix | Other | 0–1 | — | 0 | — |
| 49 | Bypass | Other | 0–0 | % | 0 | — |

**Input Select (Carrier) choices** (catalog order): LEFT, RIGHT.

**Bands choices** (catalog order): 4, 8, 12, 16.

**Freeze choices** (catalog order): 0, 1.

**Bypass Mode choices** (catalog order): MIX = 0%, MUTE FX OUT, MUTE OUT.

**Globalmix choices** (catalog order): OFF, ON.

## VolPan

**VolPan** · Instances: Vol/Pan 1 (ID 127), Vol/Pan 2 (ID 166), Vol/Pan 3 (ID 167), Vol/Pan 4 (ID 168)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Volume | Volume/Pan | 0–10 | — | 254 | 200 |
| 2 | Volume Taper | Volume/Pan | 0–3 | — | 0 | — |
| 4 | Pan Left | Volume/Pan | -50–50 | — | 0 | — |
| 5 | Pan Right | Volume/Pan | -50–50 | — | 254 | — |
| 1 | Balance | Volume/Pan | -50–50 | — | 127 | 201 |
| 6 | Bypass Mode | Volume/Pan | 0–1 | — | 0 | 255 |
| 3 | Bypass | Other | 0–0 | — | 0 | — |

**Volume Taper choices** (catalog order): LINEAR, LOG 30A, LOG 15A, LOG 10A.

**Bypass Mode choices** (catalog order): THRU, MUTE.

## PanTrem

**PanTrem** · Instances: Panner/Tremolo 1 (ID 128), Panner/Tremolo 2 (ID 129)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Type | Basic | 0–1 | — | 0 | — |
| 2 | Rate | Tremolo | 0.196–20 | Hz | 178 | 203 |
| 5 | Tempo | Tremolo | 0–29 | — | 0 | — |
| 1 | LFO Type | Tremolo | 0–8 | — | 0 | — |
| 11 | LFO Phase | Tremolo | 0–180 | deg | 0 | — |
| 4 | Duty | Tremolo | 1–99 | % | 127 | 205 |
| 3 | Depth | Tremolo | 0–100 | % | 203 | 204 |
| 7 | Level | Tremolo | -50–13.5 | dB | 200 | 201 |
| 8 | Balance | Tremolo | -50–50 | — | 127 | 202 |
| 9 | Bypass Mode | Tremolo | 0–1 | — | 0 | 255 |
| 12 | Width | Panner | 0–400 | % | 64 | 206 |
| 13 | Pan Center | Panner | -1–1 | — | 127 | — |
| 6 | Mix | Other | 0–100 | % | 254 | 200 |
| 10 | Globalmix | Other | 0–1 | — | 0 | — |
| 14 | Bypass | Other | 0–0 | % | 0 | — |

**Type choices** (catalog order): TREMOLO, PANNER.

**Tempo choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**LFO Type choices** (catalog order): SINE, TRIANGLE, SQUARE, SAW UP, SAW DOWN, RANDOM, LOG, EXP, TRAPEZOID.

**Bypass Mode choices** (catalog order): THRU, MUTE.

**Globalmix choices** (catalog order): OFF, ON.

## Wah

**Wah** · Instances: Wahwah 1 (ID 124), Wahwah 2 (ID 125)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 5 | Frequency | Wah | 200–4000 | Hz | 0 | 203 |
| 3 | Resonance | Wah | 0–10 | — | 146 | — |
| 0 | Filter Type | Wah | 0–2 | — | 1 | — |
| 1 | Frequency Min | Wah | 200–800 | Hz | 127 | — |
| 2 | Frequency Max | Wah | 1000–4000 | Hz | 127 | — |
| 4 | Tracking | Wah | 0–10 | — | 191 | — |
| 6 | Level | Wah | -50–13.5 | dB | 200 | 201 |
| 7 | Balance | Wah | -50–50 | — | 127 | 202 |
| 8 | Bypass Mode | Wah | 0–1 | — | 0 | 255 |
| 9 | Globalmix | Other | 0–0 | % | 0 | — |
| 10 | Spare1 | Other | -50–-50 | dB | 0 | — |
| 11 | Spare2 | Other | -50–-50 | — | 0 | — |
| 12 | Bypass | Other | 0–0 | OUT | 0 | — |

**Filter Type choices** (catalog order): LOWPASS, BANDPASS, PEAKING.

**Bypass Mode choices** (catalog order): THRU, MUTE.

## NoiseGate

**NoiseGate** · Instances: NoiseGate (ID 139)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Threshold | Gate | -100–0 | dB | 34 | — |
| 1 | Ratio | Gate | 1–8 | — | 172 | — |
| 2 | Release | Gate | 10–1000 | ms | 127 | — |
| 3 | Attack | Gate | 1–100 | ms | 127 | — |
| 4 | Spare2 | Other | 127–127 | — | 127 | — |
| 5 | Spare3 | Other | 127–127 | — | 127 | — |
| 6 | Bypass | Other | 127–127 | — | 127 | — |

**Spare2 choices** (catalog order): -1.00, -1.00.

**Spare3 choices** (catalog order): -1.00, -1.00.

**Bypass choices** (catalog order): -1.00, -1.00.

## Output

**Output** · Instances: Output (ID 140)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 0 | Level 1 | Output | -20–20 | dB | 127 | — |
| 1 | Level 2 | Output | -20–20 | dB | 127 | — |
| 2 | Level 3 | Output | -20–20 | dB | 127 | — |
| 3 | Level 4 | Output | -20–20 | dB | 127 | — |
| 8 | Main | Output | -20–20 | — | 127 | — |
| 4 | Balance 1 | Output | -50–50 | — | 127 | — |
| 5 | Balance 2 | Output | -50–50 | — | 127 | — |
| 6 | Balance 3 | Output | -50–50 | — | 127 | — |
| 7 | Balance 4 | Output | -50–50 | — | 127 | — |
| 9 | Spare1 | Other | -50–13.5 | dB | 200 | — |
| 10 | Spare2 | Other | -50–50 | — | 127 | — |
| 11 | Spare3 | Other | 0–1 | — | 0 | — |
| 12 | Bypass | Other | -12–-12 | dB | 0 | — |

**Spare3 choices** (catalog order): THRU, MUTE.

## Controllers

**Controllers** · Instances: Controllers (ID 141)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | LFO1 Rate | LFO1 | 0.05–20 | Hz | 127 | 200 |
| 5 | LFO1 Tempo | LFO1 | 0–29 | — | 0 | — |
| 0 | LFO1 Type (Run) | LFO1 | 0–8 | — | 0 | 206 |
| 4 | Output B Phase | LFO1 | 0–180 | deg | 254 | — |
| 3 | LFO1 Duty | LFO1 | 1–99 | % | 127 | 204 |
| 2 | LFO1 Depth | LFO1 | 0–100 | % | 254 | 202 |
| 7 | LFO2 Rate | LFO2 | 0.05–20 | Hz | 127 | 201 |
| 11 | LFO2 Tempo | LFO2 | 0–29 | — | 0 | — |
| 6 | LFO2 Type (Run) | LFO2 | 0–8 | — | 0 | 207 |
| 10 | Output B Phase | LFO2 | 0–180 | deg | 254 | — |
| 9 | LFO2 Duty | LFO2 | 1–99 | % | 127 | 205 |
| 8 | LFO2 Depth | LFO2 | 0–100 | % | 254 | 203 |
| 19 | Threshold | ADSR 1 | -80–0 | dB | 191 | — |
| 17 | Level | ADSR 1 | 0–100 | % | 127 | — |
| 12 | Mode | ADSR 1 | 0–2 | — | 0 | — |
| 13 | Retrig | ADSR 1 | 0–1 | — | 0 | — |
| 14 | Attack | ADSR 1 | 1–10000 | ms | 108 | — |
| 15 | Decay | ADSR 1 | 1–10000 | ms | 108 | — |
| 16 | Sustain | ADSR 1 | 1–10000 | ms | 108 | — |
| 18 | Release | ADSR 1 | 1–10000 | ms | 108 | — |
| 27 | Threshold | ADSR 2 | -80–0 | dB | 191 | — |
| 25 | Level | ADSR 2 | 0–100 | % | 127 | — |
| 20 | Mode | ADSR 2 | 0–2 | — | 0 | — |
| 21 | Retrig | ADSR 2 | 0–1 | — | 0 | — |
| 22 | Attack | ADSR 2 | 1–10000 | ms | 108 | — |
| 23 | Decay | ADSR 2 | 1–10000 | ms | 108 | — |
| 24 | Sustain | ADSR 2 | 1–10000 | ms | 108 | — |
| 26 | Release | ADSR 2 | 1–10000 | ms | 108 | — |
| 32 | Rate | Sequencer | 1–25 | Hz | 127 | — |
| 33 | Tempo | Sequencer | 0–29 | — | 0 | — |
| 35 | Stage 1 | Sequencer | 0–100 | % | 25 | — |
| 36 | Stage 2 | Sequencer | 0–100 | % | 203 | — |
| 37 | Stage 3 | Sequencer | 0–100 | % | 76 | — |
| 38 | Stage 4 | Sequencer | 0–100 | % | 152 | — |
| 39 | Stage 5 | Sequencer | 0–100 | % | 51 | — |
| 40 | Stage 6 | Sequencer | 0–100 | % | 229 | — |
| 41 | Stage 7 | Sequencer | 0–100 | % | 0 | — |
| 42 | Stage 8 | Sequencer | 0–100 | % | 102 | — |
| 54 | Run | Sequencer | 0–1 | — | 0 | 208 |
| 34 | Stages | Sequencer | 2–16 | — | 8 | — |
| 43 | Stage 9 | Sequencer | 0–100 | % | 0 | — |
| 44 | Stage 10 | Sequencer | 0–100 | % | 102 | — |
| 45 | Stage 11 | Sequencer | 0–100 | % | 51 | — |
| 46 | Stage 12 | Sequencer | 0–100 | % | 229 | — |
| 47 | Stage 13 | Sequencer | 0–100 | % | 152 | — |
| 48 | Stage 14 | Sequencer | 0–100 | % | 25 | — |
| 49 | Stage 15 | Sequencer | 0–100 | % | 127 | — |
| 50 | Stage 16 | Sequencer | 0–100 | % | 178 | — |
| 52 | Threshold | Envelope | -80–0 | dB | 64 | — |
| 28 | Attack | Envelope | 1–10000 | ms | 0 | — |
| 29 | Release | Envelope | 1–10000 | ms | 0 | — |
| 53 | Gain | Envelope | 1–4 | — | 0 | — |
| 30 | Tempo | Other | 30–250 | — | 95 | — |
| 31 | Tempotouse | Other | 0–1 | — | 0 | — |
| 51 | Autodelay | Other | 0–1 | — | 0 | — |
| 100 | Extern 1 | Other | 0–127 | — | 0 | — |
| 101 | Extern 2 | Other | 0–127 | — | 0 | — |
| 102 | Extern 3 | Other | 0–127 | — | 0 | — |
| 103 | Extern 4 | Other | 0–127 | — | 0 | — |
| 104 | Extern 5 | Other | 0–127 | — | 0 | — |
| 105 | Extern 6 | Other | 0–127 | — | 0 | — |
| 106 | Extern 7 | Other | 0–127 | — | 0 | — |
| 107 | Extern 8 | Other | 0–127 | — | 0 | — |

**LFO1 Tempo choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**LFO1 Type (Run) choices** (catalog order): SINE, TRIANGLE, SQUARE, SAW UP, SAW DOWN, RANDOM, LOG, EXP, TRAPEZOID.

**LFO2 Tempo choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**LFO2 Type (Run) choices** (catalog order): SINE, TRIANGLE, SQUARE, SAW UP, SAW DOWN, RANDOM, LOG, EXP, TRAPEZOID.

**Mode choices** (catalog order): ONCE, LOOP, SUST.

**Retrig choices** (catalog order): OFF, ON.

**Mode choices** (catalog order): ONCE, LOOP, SUST.

**Retrig choices** (catalog order): OFF, ON.

**Tempo choices** (catalog order): NONE, 1, 1/2 DOT, 1/2, 1/2 TRIP, 1/4 DOT, 1/4, 1/4 TRIP, 1/8 DOT, 1/8, 1/8 TRIP, 1/16 DOT, 1/16, 1/16 TRIP, 2, 1 TRIP, 15/16, 14/16, 13/16, 11/16, 10/16, 9/16, 7/16, 5/16, 1/32 DOT, 1/32, 1/32 TRIP, 1/64 DOT, 1/64, 1/64 TRIP.

**Run choices** (catalog order): OFF, ON.

**Stages choices** (catalog order): 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16.

**Tempo choices** (catalog order): (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms), (26 ms).

**Tempotouse choices** (catalog order): PRESET, GLOBAL.

**Autodelay choices** (catalog order): OFF, ON.

## FeedbackSend

**FeedbackSend** · Instances: Feedback Send (ID 142)

| ID | Control | Page | Display range | Unit | Raw default | Modifier ID |
| --- | --- | --- | --- | --- | --- | --- |
