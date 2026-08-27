#!/usr/bin/env node
/**
 * Recompress Meshy GLBs for the web pack: shrink embedded textures and
 * simplify over-tessellated meshes. Animated rigs are texture-only.
 */
import { existsSync, mkdirSync, copyFileSync, statSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { NodeIO } from '@gltf-transform/core';
import { ALL_EXTENSIONS } from '@gltf-transform/extensions';
import { dedup, prune, simplify, textureCompress, weld } from '@gltf-transform/functions';
import { MeshoptSimplifier } from 'meshoptimizer';
import sharp from 'sharp';

const ROOT = new URL('..', import.meta.url).pathname;
const MODELS = join(ROOT, 'models');
const BACKUP = join(ROOT, 'tools', '_glb_backup');

const SKIP = new Set(['ceo_dead.glb']); // unused leftover — do not ship

const TEX_ONLY = new Set(['abyssal_stalker.glb', 'ember_demon.glb']);

const TEX_512 = new Set([
	'closed_door.glb',
	'closed_elevator.glb',
	'toiletbowl.glb',
	'blood_decal_1.glb',
	'blood_decal_2.glb',
	'blood_pool.glb',
	'office_copier.glb',
	'hardcover_book.glb',
	'coffee_cup.glb',
	'executive_desk.glb',
]);

const RATIO = {
	'shotgun.glb': 0.16,
	'ceo_dead2.glb': 0.10,
	'fallen_security_guard.glb': 0.10,
	'CEO_couch_coffee_table.glb': 0.07,
	'bathroom_vanity.glb': 0.08,
	'kitchen_lunch_table.glb': 0.08,
	'refrigerator_open.glb': 0.08,
	'reception_desk.glb': 0.08,
	'mop_and_bucket.glb': 0.08,
	'broken_door.glb': 0.07,
	'closed_door.glb': 0.05,
	'closed_elevator.glb': 0.05,
	'toiletbowl.glb': 0.14,
	'blood_pool.glb': 0.16,
	'blood_decal_1.glb': 0.28,
	'blood_decal_2.glb': 0.28,
};

function texSize(name) {
	return TEX_512.has(name) ? 512 : 1024;
}

function ratioFor(name) {
	return RATIO[name] ?? 0.08;
}

function vertCount(doc) {
	let n = 0;
	for (const mesh of doc.getRoot().listMeshes()) {
		for (const prim of mesh.listPrimitives()) {
			const pos = prim.getAttribute('POSITION');
			if (pos) n += pos.getCount();
		}
	}
	return n;
}

async function processOne(name) {
	const src = join(MODELS, name);
	if (!existsSync(src)) {
		console.log(`SKIP missing ${name}`);
		return null;
	}
	mkdirSync(BACKUP, { recursive: true });
	const bak = join(BACKUP, name);
	if (!existsSync(bak)) copyFileSync(src, bak);

	const io = new NodeIO().registerExtensions(ALL_EXTENSIONS);
	const doc = await io.read(src);
	const beforeBytes = statSync(src).size;
	const beforeVerts = vertCount(doc);
	const maxDim = texSize(name);

	const transforms = [
		dedup(),
		textureCompress({
			encoder: sharp,
			resize: [maxDim, maxDim],
			quality: 76,
			limitInputPixels: false,
		}),
	];

	if (!TEX_ONLY.has(name) && beforeVerts > 8000) {
		transforms.push(
			weld({ overwrite: true }),
			simplify({
				simplifier: MeshoptSimplifier,
				ratio: ratioFor(name),
				error: 0.02,
				lockBorder: false,
			}),
		);
	}
	transforms.push(prune());
	await doc.transform(...transforms);

	const tmp = src + '.tmp.glb';
	await io.write(tmp, doc);
	copyFileSync(tmp, src);
	const { unlinkSync } = await import('node:fs');
	unlinkSync(tmp);

	const afterBytes = statSync(src).size;
	const afterDoc = await io.read(src);
	const afterVerts = vertCount(afterDoc);
	const row = {
		file: name,
		in_bytes: beforeBytes,
		out_bytes: afterBytes,
		in_verts: beforeVerts,
		out_verts: afterVerts,
		tex: maxDim,
		simplified: !TEX_ONLY.has(name) && beforeVerts > 8000,
	};
	console.log(
		`${name}: ${(beforeBytes / 1048576).toFixed(2)}MB/${beforeVerts}v → ${(afterBytes / 1048576).toFixed(2)}MB/${afterVerts}v tex≤${maxDim}`,
	);
	return row;
}

const files = [
	'shotgun.glb',
	'ceo_dead2.glb',
	'fallen_security_guard.glb',
	'CEO_couch_coffee_table.glb',
	'bathroom_vanity.glb',
	'kitchen_lunch_table.glb',
	'refrigerator_open.glb',
	'reception_desk.glb',
	'mop_and_bucket.glb',
	'broken_door.glb',
	'closed_door.glb',
	'closed_elevator.glb',
	'toiletbowl.glb',
	'blood_pool.glb',
	'blood_decal_1.glb',
	'blood_decal_2.glb',
	'abyssal_stalker.glb',
	'ember_demon.glb',
	'coffee_cup.glb',
	'executive_desk.glb',
	'hardcover_book.glb',
	'office_copier.glb',
];

const report = [];
for (const f of files) {
	try {
		const row = await processOne(f);
		if (row) report.push(row);
	} catch (err) {
		console.error(`FAIL ${f}:`, err);
		const bak = join(BACKUP, f);
		if (existsSync(bak)) copyFileSync(bak, join(MODELS, f));
		throw err;
	}
}
writeFileSync(join(ROOT, 'tools', 'glb_recompress_report.json'), JSON.stringify(report, null, 2));
console.log('wrote tools/glb_recompress_report.json');
