#!/usr/bin/env python3
"""Crop the money-shot skyline and generate short in-repo WAV stings."""
from __future__ import annotations

import math
import struct
import wave
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
TEX = ROOT / "textures"
AUD = ROOT / "audio"
SR = 22050


def write_wav(path: Path, samples: list[float], sr: int = SR) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(sr)
        frames = b"".join(
            struct.pack("<h", int(max(-1.0, min(1.0, s)) * 32767.0)) for s in samples
        )
        w.writeframes(frames)


def env(t: float, attack: float, hold: float, release: float) -> float:
    if t < attack:
        return t / attack if attack > 0 else 1.0
    if t < attack + hold:
        return 1.0
    if t < attack + hold + release:
        return 1.0 - (t - attack - hold) / release
    return 0.0


def shotgun() -> list[float]:
    n = int(SR * 0.55)
    out = []
    for i in range(n):
        t = i / SR
        e = env(t, 0.002, 0.03, 0.45)
        noise = ((i * 1103515245 + 12345) % 2147483647) / 2147483647.0 * 2.0 - 1.0
        thump = math.sin(2 * math.pi * 62 * t) * math.exp(-t * 18)
        body = math.sin(2 * math.pi * 110 * t) * math.exp(-t * 12)
        out.append((noise * 0.55 + thump * 0.7 + body * 0.35) * e)
    return out


def pistol() -> list[float]:
    n = int(SR * 0.28)
    out = []
    for i in range(n):
        t = i / SR
        e = env(t, 0.001, 0.012, 0.22)
        noise = ((i * 1664525 + 1013904223) % 2147483647) / 2147483647.0 * 2.0 - 1.0
        crack = math.sin(2 * math.pi * 420 * t) * math.exp(-t * 28)
        out.append((noise * 0.4 + crack * 0.65) * e)
    return out


def reload() -> list[float]:
    n = int(SR * 0.42)
    out = [0.0] * n
    for i in range(n):
        t = i / SR
        click = 0.0
        if 0.02 < t < 0.05:
            click += math.sin(2 * math.pi * 1800 * t) * env(t - 0.02, 0.002, 0.004, 0.02)
        if 0.16 < t < 0.22:
            click += math.sin(2 * math.pi * 900 * t) * env(t - 0.16, 0.003, 0.01, 0.04) * 0.8
        if 0.30 < t < 0.36:
            click += math.sin(2 * math.pi * 1400 * t) * env(t - 0.30, 0.002, 0.006, 0.03) * 0.7
        out[i] = click * 0.55
    return out


def empty() -> list[float]:
    n = int(SR * 0.12)
    out = []
    for i in range(n):
        t = i / SR
        out.append(math.sin(2 * math.pi * 2100 * t) * env(t, 0.001, 0.008, 0.08) * 0.35)
    return out


def hurt() -> list[float]:
    n = int(SR * 0.35)
    out = []
    for i in range(n):
        t = i / SR
        out.append(
            (math.sin(2 * math.pi * 90 * t) + 0.4 * math.sin(2 * math.pi * 48 * t))
            * env(t, 0.005, 0.04, 0.28)
            * 0.7
        )
    return out


def growl() -> list[float]:
    n = int(SR * 0.7)
    out = []
    for i in range(n):
        t = i / SR
        noise = ((i * 214013 + 2531011) % 2147483647) / 2147483647.0 * 2.0 - 1.0
        tone = math.sin(2 * math.pi * (70 + 12 * math.sin(2 * math.pi * 6 * t)) * t)
        out.append((tone * 0.55 + noise * 0.25) * env(t, 0.04, 0.2, 0.4) * 0.6)
    return out


def sting() -> list[float]:
    n = int(SR * 1.8)
    out = []
    for i in range(n):
        t = i / SR
        e = env(t, 0.08, 0.35, 1.2)
        low = math.sin(2 * math.pi * 42 * t) + 0.5 * math.sin(2 * math.pi * 63 * t)
        swell = math.sin(2 * math.pi * (180 + t * 40) * t) * 0.25
        noise = ((i * 1103515245) % 2147483647) / 2147483647.0 * 2.0 - 1.0
        out.append((low * 0.7 + swell + noise * 0.12 * e) * e * 0.85)
    return out


def crop_panes() -> None:
    src = TEX / "denver_fire_skyline.png"
    im = Image.open(src).convert("RGB")
    w, h = im.size
    third = w // 3
    names = ("denver_fire_pane_01.png", "denver_fire_pane_02.png", "denver_fire_pane_03.png")
    for i, name in enumerate(names):
        left = i * third
        right = w if i == 2 else (i + 1) * third
        im.crop((left, 0, right, h)).save(TEX / name, "PNG")
        print("wrote", TEX / name, right - left, "x", h)


def main() -> None:
    crop_panes()
    write_wav(AUD / "shotgun_fire.wav", shotgun())
    write_wav(AUD / "pistol_fire.wav", pistol())
    write_wav(AUD / "reload.wav", reload())
    write_wav(AUD / "empty.wav", empty())
    write_wav(AUD / "hurt.wav", hurt())
    write_wav(AUD / "demon_growl.wav", growl())
    write_wav(AUD / "window_sting.wav", sting())
    print("assets ok")


if __name__ == "__main__":
    main()
