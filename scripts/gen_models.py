#!/usr/bin/env python3
"""Author GLB props: executive desk, coffee cup, hardcover book, office copier."""

from __future__ import annotations

import json
import math
import struct
from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "models"
OUT.mkdir(exist_ok=True)


class Mesh:
    def __init__(self, name: str) -> None:
        self.name = name
        self.pos: list[float] = []
        self.nrm: list[float] = []
        self.uv: list[float] = []
        self.idx: list[int] = []

    def add_tri(self, a, b, c, n, uv_a, uv_b, uv_c) -> None:
        base = len(self.pos) // 3
        for p, u in ((a, uv_a), (b, uv_b), (c, uv_c)):
            self.pos.extend(p)
            self.nrm.extend(n)
            self.uv.extend(u)
        self.idx.extend((base, base + 1, base + 2))

    def add_quad(self, p00, p10, p11, p01, n, uv_scale: float = 1.0) -> None:
        u00, u10, u11, u01 = (0.0, 0.0), (uv_scale, 0.0), (uv_scale, uv_scale), (0.0, uv_scale)
        self.add_tri(p00, p10, p11, n, u00, u10, u11)
        self.add_tri(p00, p11, p01, n, u00, u11, u01)

    def add_box(self, c, s, subdiv=(1, 1, 1), uv=1.0) -> None:
        cx, cy, cz = c
        sx, sy, sz = s
        nx, ny, nz = subdiv
        hx, hy, hz = sx * 0.5, sy * 0.5, sz * 0.5
        # +Y / -Y
        for y_sign, n in ((1.0, (0.0, 1.0, 0.0)), (-1.0, (0.0, -1.0, 0.0))):
            y = cy + hy * y_sign
            for i in range(nx):
                for j in range(nz):
                    x0 = cx - hx + sx * i / nx
                    x1 = cx - hx + sx * (i + 1) / nx
                    z0 = cz - hz + sz * j / nz
                    z1 = cz - hz + sz * (j + 1) / nz
                    p00, p10, p11, p01 = (x0, y, z0), (x1, y, z0), (x1, y, z1), (x0, y, z1)
                    if y_sign < 0:
                        p10, p01 = p01, p10
                    self.add_quad(p00, p10, p11, p01, n, uv)
        # +X / -X
        for x_sign, n in ((1.0, (1.0, 0.0, 0.0)), (-1.0, (-1.0, 0.0, 0.0))):
            x = cx + hx * x_sign
            for i in range(ny):
                for j in range(nz):
                    y0 = cy - hy + sy * i / ny
                    y1 = cy - hy + sy * (i + 1) / ny
                    z0 = cz - hz + sz * j / nz
                    z1 = cz - hz + sz * (j + 1) / nz
                    p00, p10, p11, p01 = (x, y0, z0), (x, y1, z0), (x, y1, z1), (x, y0, z1)
                    if x_sign < 0:
                        p10, p01 = p01, p10
                    self.add_quad(p00, p10, p11, p01, n, uv)
        # +Z / -Z
        for z_sign, n in ((1.0, (0.0, 0.0, 1.0)), (-1.0, (0.0, 0.0, -1.0))):
            z = cz + hz * z_sign
            for i in range(nx):
                for j in range(ny):
                    x0 = cx - hx + sx * i / nx
                    x1 = cx - hx + sx * (i + 1) / nx
                    y0 = cy - hy + sy * j / ny
                    y1 = cy - hy + sy * (j + 1) / ny
                    p00, p10, p11, p01 = (x0, y0, z), (x1, y0, z), (x1, y1, z), (x0, y1, z)
                    if z_sign < 0:
                        p10, p01 = p01, p10
                    self.add_quad(p00, p10, p11, p01, n, uv)


def _minmax(vals: list[float], stride: int) -> tuple[list[float], list[float]]:
    mins = [min(vals[i::stride]) for i in range(stride)]
    maxs = [max(vals[i::stride]) for i in range(stride)]
    return mins, maxs


def write_glb(path: Path, meshes: list[Mesh], colors: list[list[float]]) -> None:
    bin_parts: list[bytes] = []
    offset = 0
    buffer_views = []
    accessors = []
    primitives_by_mesh = []

    def push(data: bytes, target: int, stride: int | None = None) -> int:
        nonlocal offset
        pad = (4 - (len(data) % 4)) % 4
        data = data + b"\x00" * pad
        view = {"buffer": 0, "byteOffset": offset, "byteLength": len(data) - pad, "target": target}
        if stride:
            view["byteStride"] = stride
        buffer_views.append(view)
        bin_parts.append(data)
        idx = len(buffer_views) - 1
        offset += len(data)
        return idx

    for mesh in meshes:
        pos_b = b"".join(struct.pack("<3f", *mesh.pos[i : i + 3]) for i in range(0, len(mesh.pos), 3))
        nrm_b = b"".join(struct.pack("<3f", *mesh.nrm[i : i + 3]) for i in range(0, len(mesh.nrm), 3))
        uv_b = b"".join(struct.pack("<2f", *mesh.uv[i : i + 2]) for i in range(0, len(mesh.uv), 2))
        idx_b = b"".join(struct.pack("<I", i) for i in mesh.idx)
        pv = push(pos_b, 34962, 12)
        nv = push(nrm_b, 34962, 12)
        uv = push(uv_b, 34962, 8)
        iv = push(idx_b, 34963)
        pmin, pmax = _minmax(mesh.pos, 3)
        accessors.append(
            {"bufferView": pv, "componentType": 5126, "count": len(mesh.pos) // 3, "type": "VEC3", "min": pmin, "max": pmax}
        )
        accessors.append({"bufferView": nv, "componentType": 5126, "count": len(mesh.nrm) // 3, "type": "VEC3"})
        accessors.append({"bufferView": uv, "componentType": 5126, "count": len(mesh.uv) // 2, "type": "VEC2"})
        accessors.append({"bufferView": iv, "componentType": 5125, "count": len(mesh.idx), "type": "SCALAR"})
        base = len(accessors) - 4
        primitives_by_mesh.append((base, base + 1, base + 2, base + 3))

    materials = []
    for color in colors:
        materials.append(
            {
                "pbrMetallicRoughness": {
                    "baseColorFactor": color,
                    "metallicFactor": 0.15 if color[0] < 0.4 else 0.05,
                    "roughnessFactor": 0.35,
                }
            }
        )

    gltf_meshes = []
    nodes = []
    for i, mesh in enumerate(meshes):
        pa, na, ua, ia = primitives_by_mesh[i]
        gltf_meshes.append(
            {
                "name": mesh.name,
                "primitives": [
                    {
                        "attributes": {"POSITION": pa, "NORMAL": na, "TEXCOORD_0": ua},
                        "indices": ia,
                        "material": min(i, len(materials) - 1),
                    }
                ],
            }
        )
        nodes.append({"name": mesh.name, "mesh": i})

    root_children = list(range(len(nodes)))
    nodes.append({"name": path.stem, "children": root_children})
    root = len(nodes) - 1

    blob = b"".join(bin_parts)
    gltf = {
        "asset": {"version": "2.0", "generator": "the-window-gen-models"},
        "buffers": [{"byteLength": len(blob)}],
        "bufferViews": buffer_views,
        "accessors": accessors,
        "materials": materials,
        "meshes": gltf_meshes,
        "nodes": nodes,
        "scenes": [{"nodes": [root]}],
        "scene": 0,
    }
    js = json.dumps(gltf, separators=(",", ":")).encode("utf-8")
    js += b" " * ((4 - (len(js) % 4)) % 4)
    blob += b"\x00" * ((4 - (len(blob) % 4)) % 4)
    gltf["buffers"][0]["byteLength"] = len(blob)
    js = json.dumps(gltf, separators=(",", ":")).encode("utf-8")
    js += b" " * ((4 - (len(js) % 4)) % 4)

    out = bytearray()
    total = 12 + 8 + len(js) + 8 + len(blob)
    out += struct.pack("<4sII", b"glTF", 2, total)
    out += struct.pack("<I4s", len(js), b"JSON")
    out += js
    out += struct.pack("<I4s", len(blob), b"BIN\x00")
    out += blob
    path.write_bytes(out)
    print(f"wrote {path} ({path.stat().st_size} bytes, {sum(len(m.idx)//3 for m in meshes)} tris)")


def desk() -> None:
    wood = Mesh("WalnutBody")
    metal = Mesh("MetalHardware")
    # Top slab + under-bevel. Depth X toward the window, long axis Z.
    wood.add_box((0.00, 0.735, 0.00), (1.12, 0.05, 2.48), (4, 1, 8), 2.2)
    wood.add_box((0.00, 0.702, 0.00), (1.06, 0.018, 2.40), (3, 1, 6), 1.8)
    # Pedestals with knee well in the middle (player side -X)
    wood.add_box((-0.18, 0.35, -0.92), (0.70, 0.70, 0.52), (2, 3, 2), 1.4)
    wood.add_box((-0.18, 0.35, 0.92), (0.70, 0.70, 0.52), (2, 3, 2), 1.4)
    # Inner knee returns
    wood.add_box((-0.02, 0.35, -0.62), (0.38, 0.70, 0.08), (1, 2, 1), 1.0)
    wood.add_box((-0.02, 0.35, 0.62), (0.38, 0.70, 0.08), (1, 2, 1), 1.0)
    # Modesty panel on the window side
    wood.add_box((0.46, 0.34, 0.00), (0.04, 0.62, 2.20), (1, 2, 6), 1.6)
    # Feet
    for z in (-1.10, -0.74, 0.74, 1.10):
        wood.add_box((-0.42, 0.03, z), (0.16, 0.06, 0.16), (1, 1, 1), 0.6)
        wood.add_box((0.22, 0.03, z), (0.16, 0.06, 0.16), (1, 1, 1), 0.6)
    # Drawer fronts (player-facing, -X)
    for z0, zs in ((-0.92, 0.42), (0.92, 0.42)):
        for i, y in enumerate((0.56, 0.38, 0.20)):
            wood.add_box((-0.535, y, z0), (0.03, 0.15, zs - 0.04), (1, 1, 2), 0.8)
            metal.add_box((-0.555, y, z0), (0.02, 0.018, 0.16), (1, 1, 1), 0.4)
    # Pencil drawer over the knee well
    wood.add_box((-0.50, 0.64, 0.00), (0.08, 0.07, 0.92), (1, 1, 3), 0.7)
    metal.add_box((-0.55, 0.64, 0.00), (0.018, 0.014, 0.20), (1, 1, 1), 0.4)
    write_glb(OUT / "executive_desk.glb", [wood, metal], [[0.36, 0.20, 0.11, 1.0], [0.55, 0.54, 0.52, 1.0]])


def coffee_cup() -> None:
    body = Mesh("CupBody")
    segs = 28
    # Lathe profile (radius, y) — cup ~9 cm
    outer = [
        (0.012, 0.000),
        (0.032, 0.004),
        (0.036, 0.012),
        (0.038, 0.040),
        (0.040, 0.070),
        (0.039, 0.086),
        (0.036, 0.090),
    ]
    inner = [
        (0.030, 0.086),
        (0.031, 0.050),
        (0.028, 0.016),
        (0.010, 0.010),
    ]
    profile = outer + inner + [(0.012, 0.000)]

    def ring(radius: float, y: float, v: float):
        pts = []
        for i in range(segs):
            a = (i / segs) * math.tau
            pts.append(((radius * math.cos(a), y, radius * math.sin(a)), (i / segs, v)))
        return pts

    rings = [ring(r, y, i / (len(profile) - 1)) for i, (r, y) in enumerate(profile)]
    for i in range(len(rings) - 1):
        a, b = rings[i], rings[i + 1]
        for s in range(segs):
            t = (s + 1) % segs
            p00, u00 = a[s]
            p10, u10 = a[t]
            p11, u11 = b[t]
            p01, u01 = b[s]
            ax = (p10[0] - p00[0], p10[1] - p00[1], p10[2] - p00[2])
            ay = (p01[0] - p00[0], p01[1] - p00[1], p01[2] - p00[2])
            n = (
                ax[1] * ay[2] - ax[2] * ay[1],
                ax[2] * ay[0] - ax[0] * ay[2],
                ax[0] * ay[1] - ax[1] * ay[0],
            )
            ln = math.sqrt(n[0] ** 2 + n[1] ** 2 + n[2] ** 2) or 1.0
            n = (n[0] / ln, n[1] / ln, n[2] / ln)
            body.add_quad(p00, p10, p11, p01, n, 1.0)
            # overwrite UVs of last 6 verts (2 tris)
            # already set by add_quad; fine

    # Handle as a bent tube
    handle = Mesh("CupHandle")
    for i in range(14):
        t = i / 13.0
        ang = math.radians(40 + 200 * t)
        cx = 0.038 + 0.022 * math.cos(ang)
        cy = 0.048 + 0.022 * math.sin(ang)
        handle.add_box((cx, cy, 0.0), (0.008, 0.008, 0.008), (1, 1, 1), 0.4)
    write_glb(OUT / "coffee_cup.glb", [body, handle], [[0.90, 0.90, 0.88, 1.0], [0.82, 0.82, 0.80, 1.0]])


def book() -> None:
    cover = Mesh("Cover")
    pages = Mesh("Pages")
    # Closed hardcover, spine on -X
    cover.add_box((0.00, 0.018, 0.00), (0.165, 0.008, 0.235), (2, 1, 2), 1.0)  # front
    cover.add_box((0.00, -0.018, 0.00), (0.165, 0.008, 0.235), (2, 1, 2), 1.0)  # back
    cover.add_box((-0.086, 0.00, 0.00), (0.012, 0.044, 0.235), (1, 1, 2), 0.8)  # spine
    pages.add_box((0.004, 0.00, 0.00), (0.150, 0.028, 0.220), (2, 1, 2), 1.2)
    write_glb(OUT / "hardcover_book.glb", [cover, pages], [[0.28, 0.08, 0.08, 1.0], [0.93, 0.90, 0.82, 1.0]])


def copier() -> None:
    body = Mesh("CopierBody")
    dark = Mesh("CopierDark")
    # Main cabinet
    body.add_box((0.00, 0.42, 0.00), (0.72, 0.84, 0.62), (3, 3, 2), 1.6)
    # Recessed paper cassette
    dark.add_box((0.00, 0.18, -0.28), (0.58, 0.10, 0.12), (2, 1, 1), 0.8)
    dark.add_box((0.00, 0.34, -0.28), (0.58, 0.10, 0.12), (2, 1, 1), 0.8)
    # Output tray
    body.add_box((0.00, 0.78, -0.42), (0.50, 0.03, 0.26), (2, 1, 1), 0.7)
    dark.add_box((0.00, 0.76, -0.42), (0.46, 0.02, 0.22), (1, 1, 1), 0.5)
    # Platen / glass bed
    dark.add_box((0.00, 0.86, 0.04), (0.64, 0.03, 0.50), (2, 1, 2), 1.0)
    # Lid slightly ajar
    body.add_box((0.00, 0.96, 0.10), (0.66, 0.04, 0.52), (3, 1, 2), 1.2)
    # Control panel wedge
    body.add_box((0.28, 0.90, -0.22), (0.16, 0.10, 0.18), (1, 1, 1), 0.5)
    dark.add_box((0.28, 0.96, -0.22), (0.12, 0.02, 0.14), (1, 1, 1), 0.4)
    # Feet
    for x, z in ((-0.30, -0.26), (0.30, -0.26), (-0.30, 0.26), (0.30, 0.26)):
        dark.add_box((x, 0.03, z), (0.08, 0.06, 0.08), (1, 1, 1), 0.3)
    write_glb(OUT / "office_copier.glb", [body, dark], [[0.78, 0.78, 0.80, 1.0], [0.12, 0.12, 0.14, 1.0]])


if __name__ == "__main__":
    desk()
    coffee_cup()
    book()
    copier()
