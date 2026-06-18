"""Synthesize placeholder game SFX as 16-bit mono WAV files (stdlib only).

Generates:
  assets/audio/click.wav    - short percussive click for each block drop
  assets/audio/perfect.wav  - bright ascending chime for a perfect stack
  assets/audio/coin.wav     - quick blip when coins are earned
  assets/audio/powerup.wav  - sparkly sweep when a power-up block appears
  assets/audio/gameover.wav - descending tone on game over

Run:  python tools/gen_sfx.py
"""
import math
import os
import struct
import wave

SAMPLE_RATE = 44100
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")


def _write(name, samples):
    path = os.path.join(OUT_DIR, name)
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)  # 16-bit
        w.setframerate(SAMPLE_RATE)
        frames = bytearray()
        for s in samples:
            s = max(-1.0, min(1.0, s))
            frames += struct.pack("<h", int(s * 32767))
        w.writeframes(bytes(frames))
    print(f"wrote {path}  ({len(samples)/SAMPLE_RATE*1000:.0f} ms)")


def tone(freq, dur, decay=8.0, vol=0.6):
    """A single sine tone with exponential decay."""
    n = int(SAMPLE_RATE * dur)
    out = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-decay * t)
        out.append(vol * env * math.sin(2 * math.pi * freq * t))
    return out


def click():
    """Short, dry click: high-ish tone + a touch of noise, very fast decay."""
    dur = 0.09
    n = int(SAMPLE_RATE * dur)
    out = []
    # simple deterministic pseudo-noise so we don't need `random`
    seed = 1234567
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-45 * t)
        seed = (1103515245 * seed + 12345) & 0x7FFFFFFF
        noise = (seed / 0x7FFFFFFF) * 2 - 1
        body = math.sin(2 * math.pi * 900 * t)
        out.append(0.7 * env * (0.7 * body + 0.3 * noise))
    return out


def perfect():
    """Bright ascending arpeggio (C5-E5-G5-C6) — a rewarding 'ding'."""
    notes = [523.25, 659.25, 783.99, 1046.50]
    step = 0.075
    total = int(SAMPLE_RATE * (step * len(notes) + 0.35))
    out = [0.0] * total
    for idx, f in enumerate(notes):
        start = int(SAMPLE_RATE * step * idx)
        seg = tone(f, 0.4, decay=6.0, vol=0.45)
        for j, s in enumerate(seg):
            if start + j < total:
                out[start + j] += s
    return out


def coin():
    """Quick two-note blip (B5 -> E6)."""
    out = tone(987.77, 0.06, decay=10, vol=0.4)
    tail = tone(1318.51, 0.12, decay=9, vol=0.4)
    return out + tail


def powerup():
    """Sparkly upward frequency sweep."""
    dur = 0.35
    n = int(SAMPLE_RATE * dur)
    out = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-4 * t)
        freq = 500 + 1600 * (t / dur)  # sweep up
        out.append(0.4 * env * math.sin(2 * math.pi * freq * t))
    return out


def gameover():
    """Descending three-note motif (G4 -> E4 -> C4)."""
    notes = [392.0, 329.63, 261.63]
    step = 0.13
    total = int(SAMPLE_RATE * (step * len(notes) + 0.3))
    out = [0.0] * total
    for idx, f in enumerate(notes):
        start = int(SAMPLE_RATE * step * idx)
        seg = tone(f, 0.35, decay=5, vol=0.45)
        for j, s in enumerate(seg):
            if start + j < total:
                out[start + j] += s
    return out


if __name__ == "__main__":
    os.makedirs(OUT_DIR, exist_ok=True)
    _write("click.wav", click())
    _write("perfect.wav", perfect())
    _write("coin.wav", coin())
    _write("powerup.wav", powerup())
    _write("gameover.wav", gameover())
