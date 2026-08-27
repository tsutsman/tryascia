#!/usr/bin/env node

import fs from "node:fs";

const contractPath = "evals/compatibility-contract.json";
const skillPath = "skills/tryascia/SKILL.md";
const corpusPath = "skills/tryascia/references/korpus.json";
const smokePath = "tests/compatibility-smoke.sh";

for (const path of [contractPath, skillPath, corpusPath, smokePath]) {
  if (!fs.existsSync(path)) throw new Error(`Відсутній compatibility artifact: ${path}`);
}

const contract = JSON.parse(fs.readFileSync(contractPath, "utf8"));
const corpus = JSON.parse(fs.readFileSync(corpusPath, "utf8"));
const skill = fs.readFileSync(skillPath, "utf8");
const smoke = fs.readFileSync(smokePath, "utf8");

const expectedPlatforms = ["codex", "claude-code", "hermes-agent", "openclaw"];
if (contract.schema_version !== "1.0") throw new Error("Compatibility contract schema має бути 1.0.");
if (contract.release_ref_env !== "TRYASCIA_REF") throw new Error("Усі інтеграції мають використовувати TRYASCIA_REF.");
if (JSON.stringify(contract.modes) !== JSON.stringify(["lite", "full", "ultra", "normal"])) {
  throw new Error("Compatibility contract має фіксувати lite/full/ultra/normal.");
}

const platforms = contract.platforms ?? {};
for (const name of expectedPlatforms) {
  const platform = platforms[name];
  if (!platform) throw new Error(`Відсутня stable інтеграція: ${name}`);
  if (platform.support !== "stable") throw new Error(`${name} має бути stable.`);
  if (!platform.installer || !fs.existsSync(platform.installer)) throw new Error(`Немає installer для ${name}.`);
  const installer = fs.readFileSync(platform.installer, "utf8");
  if (!installer.includes("TRYASCIA_REF")) throw new Error(`${name} не використовує TRYASCIA_REF.`);
  for (const envName of platform.override_env ?? []) {
    if (!installer.includes(envName)) throw new Error(`${name}: installer не підтримує ${envName}.`);
  }
  for (const path of platform.required_repo_files ?? []) {
    if (!fs.existsSync(path)) throw new Error(`${name}: відсутній canonical repo file ${path}.`);
  }
}
if (Object.keys(platforms).some((name) => !expectedPlatforms.includes(name) && platforms[name].support === "stable")) {
  throw new Error("Невідома інтеграція не може мовчки отримати stable status.");
}

const frontmatter = skill.match(/^---\n([\s\S]*?)\n---\n/);
if (!frontmatter) throw new Error("SKILL.md не має YAML frontmatter.");
if (!/^name:\s*tryascia\s*$/m.test(frontmatter[1])) throw new Error("SKILL.md frontmatter: name має бути tryascia.");
if (!/^description:\s*>?/m.test(frontmatter[1])) throw new Error("SKILL.md frontmatter: description обов'язковий.");

const runtimeForms = new Set(corpus.runtime_records.map((record) => record.form));
const candidateForms = new Set(corpus.records.filter((record) => record.runtime_status === "candidate").map((record) => record.form));
for (const form of candidateForms) {
  if (skill.includes(form)) throw new Error(`SKILL.md містить candidate форму в runtime-настановах: ${form}`);
}
for (const deprecated of contract.forbidden_runtime_forms ?? []) {
  if (skill.includes(deprecated)) throw new Error(`SKILL.md містить deprecated/replaced форму: ${deprecated}`);
}
for (const example of contract.required_runtime_examples ?? []) {
  if (!runtimeForms.has(example)) throw new Error(`Contract runtime example не accepted: ${example}`);
  if (!skill.includes(example)) throw new Error(`SKILL.md не містить contract runtime example: ${example}`);
}

for (const shared of contract.shared_canonical_files ?? []) {
  if (!fs.existsSync(shared)) throw new Error(`Відсутній canonical shared file: ${shared}`);
}
const forbiddenDuplicateDirs = ["skills/codex", "skills/claude-code", "skills/hermes", "skills/openclaw"];
for (const dir of forbiddenDuplicateDirs) {
  if (fs.existsSync(dir)) throw new Error(`Заборонене дублювання canonical skill: ${dir}`);
}

for (const token of contract.required_smoke_tokens ?? []) {
  if (!smoke.includes(token)) throw new Error(`Compatibility smoke не покриває: ${token}`);
}

console.log("OK: formal compatibility contract validated for Codex, Claude Code, Hermes Agent and OpenClaw.");
