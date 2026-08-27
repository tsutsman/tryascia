#!/usr/bin/env node

import fs from "node:fs";

const behaviorPath = "evals/behavior-policy.json";
const decisionsPath = "evals/candidate-decisions-1.1.json";
const freezePath = "evals/v1-candidate-freeze.json";
const corpusPath = "skills/tryascia/references/korpus.json";
const evalsPath = "evals/evals.json";

for (const path of [behaviorPath, decisionsPath, freezePath, corpusPath, evalsPath]) {
  if (!fs.existsSync(path)) throw new Error(`Відсутній behavioral quality artifact: ${path}`);
}

const behavior = JSON.parse(fs.readFileSync(behaviorPath, "utf8"));
const decisions = JSON.parse(fs.readFileSync(decisionsPath, "utf8"));
const freeze = JSON.parse(fs.readFileSync(freezePath, "utf8"));
const corpus = JSON.parse(fs.readFileSync(corpusPath, "utf8"));
const evals = JSON.parse(fs.readFileSync(evalsPath, "utf8"));

const requiredEvalNames = new Set([
  "candidate-guard",
  "intensity-calibration",
  "public-output-cleanliness",
  "security-auto-clarity",
  "no-user-insult",
  "mode-isolation-normal"
]);
for (const name of requiredEvalNames) {
  if (!evals.evals.some((evaluation) => evaluation.name === name)) {
    throw new Error(`Відсутній boundary eval: ${name}`);
  }
}

const frozen = freeze.remaining_candidates;
if (!Array.isArray(frozen) || frozen.length !== 10) {
  throw new Error("v1 candidate freeze має містити рівно 10 форм.");
}
if (!Array.isArray(decisions.reviewed_candidates) || decisions.reviewed_candidates.length !== frozen.length) {
  throw new Error("Потрібне явне редакторське рішення для кожного frozen candidate.");
}

const decisionByOriginal = new Map();
for (const item of decisions.reviewed_candidates) {
  if (!frozen.includes(item.original)) throw new Error(`Невідома reviewed candidate форма: ${item.original}`);
  if (decisionByOriginal.has(item.original)) throw new Error(`Дубль рішення для candidate: ${item.original}`);
  if (!["promote", "replace", "retain"].includes(item.decision)) {
    throw new Error(`Некоректне рішення для ${item.original}: ${item.decision}`);
  }
  if (!item.rationale) throw new Error(`Відсутнє обґрунтування для ${item.original}`);
  if ((item.decision === "promote" || item.decision === "replace") && (!item.resolved_form || !item.anchor_url)) {
    throw new Error(`Promote/replace для ${item.original} потребує resolved_form та anchor_url.`);
  }
  if (item.decision === "retain" && item.resolved_form && item.resolved_form !== item.original) {
    throw new Error(`Retain не може мовчки замінювати форму ${item.original}.`);
  }
  decisionByOriginal.set(item.original, item);
}
for (const form of frozen) {
  if (!decisionByOriginal.has(form)) throw new Error(`Немає редакторського рішення для ${form}.`);
}

if (corpus.accepted_record_count < 95 || corpus.candidate_record_count > 5) {
  throw new Error(`1.1 quality target не виконаний: accepted=${corpus.accepted_record_count}, candidate=${corpus.candidate_record_count}.`);
}

const records = new Map(corpus.records.map((record) => [record.form, record]));
const runtime = new Map(corpus.runtime_records.map((record) => [record.form, record]));
for (const record of corpus.records) {
  if (record.runtime_status === "candidate" && runtime.has(record.form)) {
    throw new Error(`Candidate потрапив у runtime pool: ${record.form}`);
  }
}
for (const item of decisions.reviewed_candidates) {
  if (item.decision === "retain") {
    const record = records.get(item.original);
    if (!record || record.runtime_status !== "candidate") {
      throw new Error(`Retained candidate має залишатися candidate: ${item.original}`);
    }
  } else {
    const record = records.get(item.resolved_form);
    if (!record || record.runtime_status !== "accepted" || record.citation_status !== "exact_anchor") {
      throw new Error(`Resolved форма має бути accepted exact_anchor: ${item.resolved_form}`);
    }
  }
}

const requiredModes = ["lite", "full", "ultra", "normal"];
for (const mode of requiredModes) {
  if (!behavior.modes?.[mode]) throw new Error(`Behavior policy не описує режим ${mode}.`);
}
const requiredContexts = ["public_output", "security", "irreversible", "user_target", "routine"];
for (const context of requiredContexts) {
  if (!behavior.contexts?.[context]) throw new Error(`Behavior policy не описує context ${context}.`);
}
if (!Array.isArray(behavior.fixtures) || behavior.fixtures.length < 10) {
  throw new Error("Behavior policy має містити щонайменше 10 executable fixtures.");
}

function evaluateFixture(fixture) {
  const mode = behavior.modes[fixture.mode];
  const context = behavior.contexts[fixture.context];
  if (!mode || !context) return false;
  const forms = fixture.forms ?? [];

  if (mode.allow_style === false && forms.length > 0) return false;
  if (context.allow_profanity === false && forms.length > 0) return false;
  if (context.allow_user_target === false && fixture.target === "user") return false;

  for (const form of forms) {
    const record = runtime.get(form);
    if (!record) return false;
    if (mode.allowed_registers && !mode.allowed_registers.includes(record.register)) return false;
    if (Number.isFinite(fixture.incident_intensity) && record.intensity > fixture.incident_intensity + (behavior.intensity_tolerance ?? 1)) {
      return false;
    }
  }
  return true;
}

const seenFixtureNames = new Set();
for (const fixture of behavior.fixtures) {
  if (!fixture.name || seenFixtureNames.has(fixture.name)) throw new Error(`Некоректна/дубльована fixture: ${fixture.name}`);
  seenFixtureNames.add(fixture.name);
  if (!["allow", "deny"].includes(fixture.expected)) throw new Error(`Fixture ${fixture.name} має некоректний expected.`);
  const actual = evaluateFixture(fixture) ? "allow" : "deny";
  if (actual !== fixture.expected) {
    throw new Error(`Behavior fixture ${fixture.name}: expected=${fixture.expected}, actual=${actual}`);
  }
}

console.log(`OK: behavioral policy executable; ${decisions.reviewed_candidates.length} candidate decisions; accepted=${corpus.accepted_record_count}, candidate=${corpus.candidate_record_count}.`);
