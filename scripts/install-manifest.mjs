#!/usr/bin/env node

import crypto from "node:crypto";
import fs from "node:fs";
import path from "node:path";

const root = process.cwd();
const manifestPath = path.join(root, "install-manifest.sha256");
const write = process.argv.includes("--write");

const files = [
  "codex/AGENTS-tryascia.md",
  "output-styles/tryascia.md",
  "scripts/install-common.sh",
  "skills/tryascia/SKILL.md",
  "skills/tryascia/references/dzherela.md",
  "skills/tryascia/references/korpus-100.md",
  "skills/tryascia/references/korpus.json",
  "skills/tryascia/references/ontologia.md",
  "skills/tryascia/references/polityka-korpusu.md",
  "skills/tryascia/references/sceny.md",
  "skills/tryascia/references/slovar.md",
  "skills/tryascia/references/verifikatsiya.md",
].sort();

const lines = files.map((relativePath) => {
  const absolutePath = path.join(root, relativePath);
  if (!fs.existsSync(absolutePath) || !fs.statSync(absolutePath).isFile()) {
    throw new Error(`Відсутній install payload: ${relativePath}`);
  }
  const digest = crypto.createHash("sha256").update(fs.readFileSync(absolutePath)).digest("hex");
  return `${digest}  ${relativePath}`;
});

const expected = `${lines.join("\n")}\n`;

if (write) {
  fs.writeFileSync(manifestPath, expected, "utf8");
  console.log(`OK: записано ${path.relative(root, manifestPath)} для ${files.length} payload-файлів.`);
  process.exit(0);
}

if (!fs.existsSync(manifestPath)) {
  console.error("Відсутній install-manifest.sha256. Запусти: node scripts/install-manifest.mjs --write");
  process.exit(1);
}

const actual = fs.readFileSync(manifestPath, "utf8");
if (actual !== expected) {
  console.error("install-manifest.sha256 має drift. Запусти: node scripts/install-manifest.mjs --write");
  process.exit(1);
}

console.log(`OK: install-manifest.sha256 синхронізований (${files.length} payload-файлів).`);
