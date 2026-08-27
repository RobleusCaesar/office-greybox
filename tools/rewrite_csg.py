#!/usr/bin/env python3
"""Convert level.tscn CSGBox3D architecture/furniture to MeshInstance3D.

Boolean walls (door/vent cuts) use Godot-baked ArrayMesh from tools/bake_architecture.gd.
Cut children stay CSGBox3D so QA can still read operation/size.
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TSCN = ROOT / "scenes" / "level.tscn"
MANIFEST = ROOT / "tools" / "csg_bake_manifest.json"

NODE_RE = re.compile(
    r'^\[node name="([^"]+)" type="([^"]+)"(?: parent="([^"]*)")?\]\s*$'
)


def parse_blocks(text: str) -> list[tuple[str, str]]:
    """Return (header_line, body) blocks. Header includes the [tag] line."""
    lines = text.splitlines(keepends=True)
    blocks: list[tuple[str, str]] = []
    i = 0
    while i < len(lines):
        if lines[i].startswith("["):
            header = lines[i]
            i += 1
            body_lines: list[str] = []
            while i < len(lines) and not lines[i].startswith("["):
                body_lines.append(lines[i])
                i += 1
            blocks.append((header, "".join(body_lines)))
        else:
            blocks.append(("", lines[i]))
            i += 1
    return blocks


def node_path(name: str, parent: str | None) -> str:
    if not parent or parent == ".":
        return name
    return f"{parent}/{name}"


def field(body: str, key: str, default: str | None = None) -> str | None:
    m = re.search(rf"^{re.escape(key)} = (.+)$", body, re.M)
    return m.group(1) if m else default


def main() -> None:
    manifest = json.loads(MANIFEST.read_text()) if MANIFEST.exists() else {}
    text = TSCN.read_text()
    blocks = parse_blocks(text)

    # First pass: collect CSGBox3D nodes and parent→children.
    nodes: list[dict] = []
    for idx, (header, body) in enumerate(blocks):
        m = NODE_RE.match(header.strip())
        if not m or m.group(2) != "CSGBox3D":
            continue
        name, _typ, parent = m.group(1), m.group(2), m.group(3)
        path = node_path(name, parent)
        nodes.append(
            {
                "idx": idx,
                "name": name,
                "parent": parent or "",
                "path": path,
                "header": header,
                "body": body,
            }
        )

    children: dict[str, list[str]] = {}
    by_path = {n["path"]: n for n in nodes}
    for n in nodes:
        if n["parent"] in by_path or n["parent"] in {p["path"] for p in nodes}:
            children.setdefault(n["parent"], []).append(n["path"])

    boolean_parents = set(manifest.keys())
    cut_paths = set()
    for p in boolean_parents:
        for c in children.get(p, []):
            cut_paths.add(c)

    new_ext: list[str] = []
    ext_ids: dict[str, str] = {}
    ext_i = 200
    for path, info in manifest.items():
        mesh_res = info["mesh"]
        eid = f"bake_{ext_i}"
        ext_i += 1
        ext_ids[path] = eid
        new_ext.append(f'[ext_resource type="ArrayMesh" path="{mesh_res}" id="{eid}"]\n')
        col = info.get("col") or ""
        if col:
            cid = f"bakecol_{ext_i}"
            ext_i += 1
            ext_ids[path + "#col"] = cid
            new_ext.append(f'[ext_resource type="Shape3D" path="{col}" id="{cid}"]\n')

    sub_i = 1
    converted = 0
    baked = 0
    skipped_cuts = 0

    out_blocks: list[tuple[str, str]] = []
    for header, body in blocks:
        m = NODE_RE.match(header.strip()) if header else None
        if not m or m.group(2) != "CSGBox3D":
            out_blocks.append((header, body))
            continue

        name, parent = m.group(1), m.group(3)
        path = node_path(name, parent)

        if path in cut_paths:
            skipped_cuts += 1
            if "visible =" not in body:
                if "use_collision = false" in body:
                    body = body.replace("use_collision = false", "visible = false\nuse_collision = false", 1)
                else:
                    body = "visible = false\n" + body
            out_blocks.append((header, body))
            continue

        size = field(body, "size", "Vector3(1, 1, 1)")
        xform = field(body, "transform")
        mat = field(body, "material")
        desc = field(body, "editor_description")
        use_col = (field(body, "use_collision", "false") or "false").strip()
        layer = field(body, "collision_layer", "1")
        mask = field(body, "collision_mask", "1")

        extra_lines = []
        if xform:
            extra_lines.append(f"transform = {xform}\n")
        extra_lines.append(f"metadata/csg_size = {size}\n")
        if desc:
            extra_lines.append(f"editor_description = {desc}\n")

        if path in boolean_parents:
            eid = ext_ids[path]
            header_n = header.replace('type="CSGBox3D"', 'type="MeshInstance3D"')
            body_n = "".join(extra_lines)
            body_n += f'mesh = ExtResource("{eid}")\n'
            if mat:
                body_n += f"material_override = {mat}\n"
            out_blocks.append((header_n, body_n))
            if use_col == "true" and path + "#col" in ext_ids:
                cid = ext_ids[path + "#col"]
                parent_path = path
                out_blocks.append(
                    (
                        f'[node name="BakedBody" type="StaticBody3D" parent="{parent_path}"]\n',
                        f"collision_layer = {layer}\ncollision_mask = {mask}\n",
                    )
                )
                out_blocks.append(
                    (
                        f'[node name="BakedCol" type="CollisionShape3D" parent="{parent_path}/BakedBody"]\n',
                        f'shape = ExtResource("{cid}")\n',
                    )
                )
            baked += 1
            continue

        # Simple box → BoxMesh + optional BoxShape3D.
        mesh_id = f"BakeBoxMesh_{sub_i}"
        shape_id = f"BakeBoxShape_{sub_i}"
        sub_i += 1
        mesh_body = f"size = {size}\n"
        if mat:
            mesh_body += f"material = {mat}\n"
        out_blocks.append((f'[sub_resource type="BoxMesh" id="{mesh_id}"]\n', mesh_body))
        header_n = header.replace('type="CSGBox3D"', 'type="MeshInstance3D"')
        body_n = "".join(extra_lines)
        body_n += f'mesh = SubResource("{mesh_id}")\n'
        if mat:
            body_n += f"material_override = {mat}\n"
        out_blocks.append((header_n, body_n))
        if use_col == "true":
            out_blocks.append((f'[sub_resource type="BoxShape3D" id="{shape_id}"]\n', f"size = {size}\n"))
            parent_path = path
            out_blocks.append(
                (
                    f'[node name="BakedBody" type="StaticBody3D" parent="{parent_path}"]\n',
                    f"collision_layer = {layer}\ncollision_mask = {mask}\n",
                )
            )
            out_blocks.append(
                (
                    f'[node name="BakedCol" type="CollisionShape3D" parent="{parent_path}/BakedBody"]\n',
                    f'shape = SubResource("{shape_id}")\n',
                )
            )
        converted += 1

    # Rebuild file: keep preamble, inject ext_resources after existing ones,
    # then remaining blocks. SubResources for boxes are interleaved — Godot
    # allows sub_resources anywhere before use, but convention is before nodes.
    # Collect injected sub_resources and move them before the first [node.
    preamble: list[tuple[str, str]] = []
    ext: list[tuple[str, str]] = []
    subs: list[tuple[str, str]] = []
    rest: list[tuple[str, str]] = []
    seen_node = False
    for header, body in out_blocks:
        tag = header.strip()
        if tag.startswith("[gd_scene"):
            preamble.append((header, body))
        elif tag.startswith("[ext_resource"):
            ext.append((header, body))
        elif tag.startswith("[sub_resource"):
            subs.append((header, body))
        elif tag.startswith("[node") or seen_node:
            seen_node = True
            rest.append((header, body))
        else:
            preamble.append((header, body))

    ext.extend((h, "") for h in new_ext)

    load_steps = 1 + len(ext) + len(subs)
    new_preamble: list[tuple[str, str]] = []
    for header, body in preamble:
        if header.startswith("[gd_scene"):
            header = re.sub(r"load_steps=\d+", f"load_steps={load_steps}", header)
        new_preamble.append((header, body))

    chunks: list[str] = []
    for header, body in new_preamble + ext + subs + rest:
        chunks.append(header)
        chunks.append(body)
        if header.startswith("[") and not body.endswith("\n") and body:
            chunks.append("\n")
    out = "".join(chunks)
    if not out.endswith("\n"):
        out += "\n"
    TSCN.write_text(out)
    print(
        f"rewrite_csg: simple={converted} boolean={baked} cuts_kept={skipped_cuts} "
        f"ext+{len(new_ext)} load_steps={load_steps}"
    )


if __name__ == "__main__":
    main()
