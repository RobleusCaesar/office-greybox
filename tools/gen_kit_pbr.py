#!/usr/bin/env python3
"""Tileable kit PBR (albedo / normal / roughness). Not packed — tools/* is excluded."""

from __future__ import annotations

import math
from pathlib import Path

import numpy as np
from PIL import Image

OUT = Path("/workspace/textures/kit")
N = 1024


def wrap(i: np.ndarray, n: int = N) -> np.ndarray:
    return np.mod(i, n)


def value_noise(n: int, cell: int, seed: int) -> np.ndarray:
    rng = np.random.default_rng(seed)
    gw = n // cell + 3
    g = rng.random((gw, gw))
    ys = np.arange(n)[:, None]
    xs = np.arange(n)[None, :]
    fy = (ys % cell) / cell
    fx = (xs % cell) / cell
    # smootherstep
    sy = fy * fy * fy * (fy * (fy * 6.0 - 15.0) + 10.0)
    sx = fx * fx * fx * (fx * (fx * 6.0 - 15.0) + 10.0)
    iy = (ys // cell).astype(np.int32)
    ix = (xs // cell).astype(np.int32)
    v00 = g[iy, ix]
    v10 = g[iy, ix + 1]
    v01 = g[iy + 1, ix]
    v11 = g[iy + 1, ix + 1]
    return v00 * (1 - sx) * (1 - sy) + v10 * sx * (1 - sy) + v01 * (1 - sx) * sy + v11 * sx * sy


def fbm(n: int, seed: int, octaves: int = 5, start: int = 64, gain: float = 0.52) -> np.ndarray:
    acc = np.zeros((n, n), dtype=np.float64)
    amp = 1.0
    total = 0.0
    cell = start
    for o in range(octaves):
        if cell < 2:
            break
        acc += amp * value_noise(n, cell, seed + o * 17)
        total += amp
        amp *= gain
        cell //= 2
    return acc / total


def wrap_diff(h: np.ndarray, axis: int) -> np.ndarray:
    return np.roll(h, -1, axis=axis) - np.roll(h, 1, axis=axis)


def height_to_normal(h: np.ndarray, strength: float) -> np.ndarray:
    dx = wrap_diff(h, 1) * strength
    dy = wrap_diff(h, 0) * strength
    nz = np.ones_like(h)
    inv = 1.0 / np.sqrt(dx * dx + dy * dy + nz * nz)
    n = np.stack((0.5 - 0.5 * dx * inv, 0.5 + 0.5 * dy * inv, 0.5 + 0.5 * nz * inv), axis=-1)
    return np.clip(n, 0.0, 1.0)


def save_rgb(name: str, arr: np.ndarray) -> None:
    img = Image.fromarray(np.clip(arr * 255.0, 0, 255).astype(np.uint8), "RGB")
    path = OUT / name
    img.save(path, "PNG", optimize=True)
    print(f"wrote {path} {path.stat().st_size}")


def save_gray(name: str, arr: np.ndarray) -> None:
    g = np.clip(arr * 255.0, 0, 255).astype(np.uint8)
    img = Image.fromarray(g, "L").convert("RGB")
    path = OUT / name
    img.save(path, "PNG", optimize=True)
    print(f"wrote {path} {path.stat().st_size}")


def drywall() -> None:
    # One 4-ft sheet: field + paper-tape edge + orange-peel.
    peel = fbm(N, 11, 6, 48, 0.55)
    blotch = fbm(N, 29, 4, 160, 0.6)
    specks = np.random.default_rng(4).random((N, N))
    ys = np.linspace(0, 1, N)[:, None]
    xs = np.linspace(0, 1, N)[None, :]
    # Paper-tape joints at the sheet edge (kit seam).
    edge = np.minimum(np.minimum(xs, 1.0 - xs), np.minimum(ys, 1.0 - ys))
    tape = np.clip(1.0 - edge * 28.0, 0.0, 1.0)
    tape = tape * tape
    # Hairline mud ridge just inside the tape.
    ridge = np.exp(-((edge - 0.018) * 90.0) ** 2)
    # Kick scuffs live at the bottom of the sheet (V=1).
    kick = np.clip((ys - 0.86) / 0.14, 0.0, 1.0)
    dirt = fbm(N, 71, 4, 96, 0.5)
    base = np.array([0.93, 0.89, 0.80])
    mud = np.array([0.88, 0.82, 0.70])
    scuff = np.array([0.72, 0.66, 0.56])
    field = peel * 0.07 + blotch * 0.05 - 0.04
    rgb = base + field[..., None] + tape[..., None] * (mud - base) * 0.55
    rgb = rgb + ridge[..., None] * np.array([0.04, 0.03, 0.02])
    rgb = rgb - kick[..., None] * (0.10 + 0.12 * dirt[..., None]) * (base - scuff)
    rgb = rgb - (specks > 0.993).astype(np.float64)[..., None] * 0.06
    rgb = np.clip(rgb, 0.0, 1.0)
    h = peel * 0.55 + blotch * 0.25 + tape * 0.35 + ridge * 0.8 - kick * dirt * 0.4
    rough = 0.84 + peel * 0.08 + tape * 0.04 - ridge * 0.03 + kick * 0.05
    save_rgb("tex_kit_drywall.png", rgb)
    save_rgb("tex_kit_drywall_n.png", height_to_normal(h, 7.5))
    save_gray("tex_kit_drywall_r.png", np.clip(rough, 0.72, 0.96))


def carpet() -> None:
    # One 24-inch loop-pile tile. Dry. Seamed edge. Not wet stone.
    rng = np.random.default_rng(42)
    pile = fbm(N, 8, 6, 32, 0.48)
    nap = fbm(N, 19, 5, 20, 0.5)
    # Directional loop streaks (commercial broadloom / tile).
    ys, xs = np.mgrid[0:N, 0:N]
    streak = 0.5 + 0.5 * np.sin((xs * 0.41 + ys * 0.07) + pile * 4.0)
    loops = 0.5 + 0.5 * np.sin(xs * 0.95 + nap * 6.0) * np.sin(ys * 0.22)
    # Tile rebate / seam (holds a close-up as a real carpet tile).
    t = np.linspace(0, 1, N)
    edge = np.minimum(np.minimum(t[None, :], 1.0 - t[None, :]), np.minimum(t[:, None], 1.0 - t[:, None]))
    seam = np.clip(1.0 - edge * 42.0, 0.0, 1.0)
    seam = seam ** 1.6
    lint = rng.random((N, N))
    base = np.array([0.70, 0.58, 0.46])
    fiber = np.array([0.78, 0.66, 0.52])
    dark = np.array([0.42, 0.34, 0.26])
    mix = 0.55 * pile + 0.25 * nap + 0.20 * streak
    rgb = base * (0.88 + 0.18 * mix[..., None]) + fiber * (0.10 * loops[..., None])
    rgb = rgb * (1.0 - seam[..., None] * 0.22) + dark * seam[..., None] * 0.22
    rgb = rgb - (lint > 0.997).astype(np.float64)[..., None] * 0.05
    rgb = np.clip(rgb, 0.0, 1.0)
    h = pile * 0.45 + nap * 0.35 + loops * 0.15 - seam * 0.7
    # Dry pile: very high roughness. Seams a hair more matte.
    rough = 0.90 + pile * 0.05 + nap * 0.03 + seam * 0.02
    save_rgb("tex_kit_carpet.png", rgb)
    save_rgb("tex_kit_carpet_n.png", height_to_normal(h, 5.2))
    save_gray("tex_kit_carpet_r.png", np.clip(rough, 0.88, 0.98))


def ceiling() -> None:
    # One 24-inch tegular acoustic tile.
    fissure = fbm(N, 3, 6, 40, 0.5)
    rng = np.random.default_rng(99)
    ys = np.linspace(0, 1, N)[:, None]
    xs = np.linspace(0, 1, N)[None, :]
    edge = np.minimum(np.minimum(xs, 1.0 - xs), np.minimum(ys, 1.0 - ys))
    tegular = np.clip(1.0 - edge * 36.0, 0.0, 1.0) ** 1.4
    # Pin-perforations, tileable grid, skip the tegular band.
    gy = (np.arange(N)[:, None] % 14).astype(np.float64)
    gx = (np.arange(N)[None, :] % 14).astype(np.float64)
    hole = ((gy - 6.5) ** 2 + (gx - 6.5) ** 2) < 3.4
    hole = hole & (edge > 0.045)
    jitter = rng.random((N, N)) > 0.18
    hole = hole & jitter
    base = np.array([0.90, 0.88, 0.83])
    rec = np.array([0.72, 0.70, 0.66])
    rgb = base + (fissure - 0.5)[..., None] * 0.06
    rgb = rgb * (1.0 - tegular[..., None] * 0.18) + rec * tegular[..., None] * 0.18
    rgb = np.where(hole[..., None], rec * 0.55, rgb)
    rgb = np.clip(rgb, 0.0, 1.0)
    h = fissure * 0.35 - tegular * 0.85 - hole.astype(np.float64) * 1.4
    rough = 0.88 + fissure * 0.06 + tegular * 0.04 + hole.astype(np.float64) * 0.05
    save_rgb("tex_kit_ceiling.png", rgb)
    save_rgb("tex_kit_ceiling_n.png", height_to_normal(h, 8.0))
    save_gray("tex_kit_ceiling_r.png", np.clip(rough, 0.82, 0.97))


def trim() -> None:
    grain = fbm(N, 14, 5, 80, 0.55)
    fine = fbm(N, 33, 4, 24, 0.5)
    ys = np.linspace(0, 1, N)[:, None]
    # Soft profile: thicker at the top cap.
    cap = np.clip(1.0 - np.abs(ys - 0.12) * 16.0, 0.0, 1.0)
    shoe = np.clip(1.0 - np.abs(ys - 0.92) * 14.0, 0.0, 1.0)
    base = np.array([0.20, 0.16, 0.12])
    hi = np.array([0.30, 0.24, 0.18])
    rgb = base + (grain - 0.5)[..., None] * 0.06 + (fine - 0.5)[..., None] * 0.03
    rgb = rgb + cap[..., None] * (hi - base) * 0.45 + shoe[..., None] * 0.03
    rgb = np.clip(rgb, 0.0, 1.0)
    h = grain * 0.3 + fine * 0.2 + cap * 0.7 + shoe * 0.4
    # Painted trim: satin, not chrome. No wet stone.
    rough = 0.46 + grain * 0.08 - cap * 0.04
    save_rgb("tex_kit_trim.png", rgb)
    save_rgb("tex_kit_trim_n.png", height_to_normal(h, 4.5))
    save_gray("tex_kit_trim_r.png", np.clip(rough, 0.38, 0.62))


def box() -> None:
    kraft = fbm(N, 21, 5, 56, 0.52)
    rng = np.random.default_rng(5)
    ys = np.linspace(0, 1, N)[:, None]
    xs = np.linspace(0, 1, N)[None, :]
    # Corrugation read through the liner.
    flute = 0.5 + 0.5 * np.sin(xs * math.pi * 42.0 + kraft * 1.4)
    seam = np.exp(-((xs - 0.5) * 70.0) ** 2)
    tape = (np.abs(ys - 0.5) < 0.07).astype(np.float64)
    tape_edge = np.exp(-((np.abs(ys - 0.5) - 0.07) * 80.0) ** 2)
    speck = rng.random((N, N))
    base = np.array([0.72, 0.56, 0.36])
    dark = np.array([0.50, 0.38, 0.24])
    tape_c = np.array([0.86, 0.80, 0.62])
    rgb = base + (kraft - 0.5)[..., None] * 0.10 + (flute - 0.5)[..., None] * 0.05
    rgb = rgb * (1.0 - seam[..., None] * 0.18) + dark * seam[..., None] * 0.18
    rgb = rgb * (1.0 - tape[..., None] * 0.55) + tape_c * tape[..., None] * 0.55
    rgb = rgb + tape_edge[..., None] * 0.04
    rgb = rgb - (speck > 0.994).astype(np.float64)[..., None] * 0.06
    rgb = np.clip(rgb, 0.0, 1.0)
    h = kraft * 0.35 + flute * 0.25 + seam * 0.4 + tape * 0.15
    rough = 0.80 + kraft * 0.08 - tape * 0.22 + flute * 0.03
    save_rgb("tex_kit_box.png", rgb)
    save_rgb("tex_kit_box_n.png", height_to_normal(h, 6.0))
    save_gray("tex_kit_box_r.png", np.clip(rough, 0.52, 0.92))


def fixture() -> None:
    # Warm fluorescent diffuser — used as emission albedo.
    grain = fbm(N, 60, 3, 64, 0.5)
    rgb = np.array([1.00, 0.92, 0.74]) * (0.92 + 0.08 * grain[..., None])
    save_rgb("tex_kit_fixture.png", np.clip(rgb, 0.0, 1.0))


def write_imports() -> None:
    albedo = """[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://kit{uid}"
path="res://.godot/imported/{name}-kit.ctex"
metadata={{
"vram_texture": false
}}

[deps]

source_file="res://textures/kit/{name}"
dest_files=["res://.godot/imported/{name}-kit.ctex"]

[params]

compress/mode=4
compress/high_quality=false
compress/lossy_quality=0.7
compress/uastc_level=0
compress/rdo_quality_loss=0.0
compress/hdr_compression=1
compress/normal_map={nmap}
compress/channel_pack=0
mipmaps/generate=true
mipmaps/limit=-1
roughness/mode=0
roughness/src_normal=""
process/channel_remap/red=0
process/channel_remap/green=1
process/channel_remap/blue=2
process/channel_remap/alpha=3
process/fix_alpha_border=true
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=1024
detect_3d/compress_to=1
"""
    for i, name in enumerate(sorted(p.name for p in OUT.glob("*.png"))):
        nmap = 1 if name.endswith("_n.png") else 0
        (OUT / f"{name}.import").write_text(
            albedo.format(name=name, nmap=nmap, uid=f"{1000 + i}kitpbr"),
            encoding="utf-8",
        )


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    drywall()
    carpet()
    ceiling()
    trim()
    box()
    fixture()
    write_imports()
    print("KIT_PBR_OK")


if __name__ == "__main__":
    main()
