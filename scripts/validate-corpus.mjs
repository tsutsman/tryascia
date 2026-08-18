#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";

const root = process.cwd();
const markdownPath = path.join(root, "skills/tryascia/references/korpus-100.md");
const jsonPath = path.join(root, "skills/tryascia/references/korpus.json");
const policyPath = path.join(root, "evals/corpus-policy.json");
const anchorPaths = [
  path.join(root, "evals/verified-anchors-base.json"),
  path.join(root, "evals/verified-anchors-beta3.json"),
  path.join(root, "evals/verified-anchors-rc1.json"),
];

const markdown = fs.readFileSync(markdownPath, "utf8");
const policy = JSON.parse(fs.readFileSync(policyPath, "utf8"));

const sourceUrls = {
  "С": "https://irbis-nbuv.gov.ua/ulib/item/UKR0001861",
  "Ф": "https://www.i-franko.name/uk/Folklore/1901/GalRusProverbs.html",
  "Н": "https://archive.org/details/nomis1864",
  "Г": "https://hrinchenko.com/",
  "К": "https://uk.wikisource.org/wiki/Твори_(Котляревський,_1922)/Том_1/Енеїда",
  "Л": "https://uk.wikisource.org/wiki/Кайдашева_сім’я",
};

const errors = [];
const exactCitations = {};

for (const anchorPath of anchorPaths) {
  const anchors = JSON.parse(fs.readFileSync(anchorPath, "utf8"));
  for (const [form, citations] of Object.entries(anchors)) {
    if (Object.hasOwn(exactCitations, form)) {
      errors.push("Дубль exact anchor між файлами: " + form);
      continue;
    }
    if (!Array.isArray(citations) || citations.length === 0) {
      errors.push("Порожній список exact anchors для форми: " + form);
      continue;
    }
    for (const citation of citations) {
      if (!citation || typeof citation.url !== "string" || !citation.url.startsWith("https://")) {
        errors.push("Некоректний URL exact anchor для форми: " + form);
      }
      if (!citation || typeof citation.note !== "string" || citation.note.trim().length === 0) {
        errors.push("Порожня примітка exact anchor для форми: " + form);
      }
    }
    exactCitations[form] = citations;
  }
}

const rowPattern = /^\|\s*(\d+)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*(\d+)\s*\|\s*([^|]+?)\s*\|\s*([ABC])\s*\|$/gm;
const rows = [...markdown.matchAll(rowPattern)].map((match) => ({
  id: Number(match[1]),
  form: match[2].trim(),
  meaning: match[3].trim(),
  intensity: Number(match[4]),
  layer: match[5].trim(),
  state: match[6],
}));

const supportedSourceCodes = new Set(Object.keys(sourceUrls));
const normalizedForms = new Set();
const corpusForms = new Set(rows.map((row) => row.form));

if (rows.length !== 100) {
  errors.push("Очікувалося 100 записів, знайдено " + rows.length + ".");
}

for (const [index, row] of rows.entries()) {
  const expectedId = index + 1;
  if (row.id !== expectedId) {
    errors.push("Порушена нумерація біля запису " + row.id + "; очікувався " + expectedId + ".");
  }

  const normalizedForm = row.form.normalize("NFC").toLocaleLowerCase("uk-UA");
  if (normalizedForms.has(normalizedForm)) {
    errors.push("Дубль форми: " + row.form);
  }
  normalizedForms.add(normalizedForm);

  if (!row.form || !row.meaning) {
    errors.push("Порожня форма або значення у записі " + row.id + ".");
  }
  if (/[A-Za-z]/u.test(row.form)) {
    errors.push("Латинська літера у формі запису " + row.id + ": " + row.form);
  }
  if (row.intensity < 1 || row.intensity > 10) {
    errors.push("Неприпустимий рівень у записі " + row.id + ".");
  }

  const sourceCodes = row.layer
    .replaceAll("→А", "")
    .split("/")
    .map((code) => code.trim())
    .filter(Boolean);

  if (sourceCodes.length === 0) {
    errors.push("Відсутній джерельний код у записі " + row.id + ".");
  }
  for (const code of sourceCodes) {
    if (!supportedSourceCodes.has(code)) {
      errors.push("Невідомий джерельний код у записі " + row.id + ": " + code);
    }
  }
}

for (const form of Object.keys(exactCitations)) {
  if (!corpusForms.has(form)) {
    errors.push("Exact anchor не відповідає жодній формі корпусу: " + form);
  }
}

if (errors.length > 0) {
  console.error(errors.join("\n"));
  process.exit(1);
}

const records = rows.map((row) => {
  const sourceCodes = row.layer
    .replaceAll("→А", "")
    .split("/")
    .map((code) => code.trim())
    .filter(Boolean);
  const citations = exactCitations[row.form] ?? [];
  const reviewStatus = row.state === "C" || row.layer.includes("→А")
    ? "adaptation"
    : row.state === "B"
      ? "derivative"
      : "screened";

  return {
    id: row.id,
    form: row.form,
    meaning: row.meaning,
    intensity: row.intensity,
    register: row.intensity <= 3 ? "lite" : row.intensity <= 7 ? "full" : "ultra",
    target: "system_or_process",
    source_codes: sourceCodes,
    source_urls: sourceCodes.map((code) => sourceUrls[code]),
    state: row.state,
    review_status: reviewStatus,
    citation_status: citations.length > 0 ? "exact_anchor" : "candidate",
    runtime_status: citations.length > 0 ? "accepted" : "candidate",
    exact_citations: citations,
    note: citations.length > 0
      ? "Є точна опорна сторінка; варіант форми може відрізнятися від оригінального написання."
      : "Кандидат: джерельний шар визначено, але точний запис або сторінку ще треба додати під час редакторської верифікації.",
  };
});

const acceptedRecords = records.filter((record) => record.runtime_status === "accepted");
const candidateRecords = records.filter((record) => record.runtime_status === "candidate");

if (policy.default_runtime_status !== "accepted") {
  errors.push("Політика має використовувати accepted як runtime-статус за замовчуванням.");
}
if (acceptedRecords.length < policy.release_gate.minimum_accepted_records) {
  errors.push(
    "Прийнятих записів менше за release gate: " +
      acceptedRecords.length + " < " + policy.release_gate.minimum_accepted_records + "."
  );
}
if (candidateRecords.length > policy.release_gate.maximum_candidate_records) {
  errors.push(
    "Кандидатів більше за release gate: " +
      candidateRecords.length + " > " + policy.release_gate.maximum_candidate_records + "."
  );
}
if (acceptedRecords.some((record) => record.citation_status !== "exact_anchor")) {
  errors.push("До accepted потрапив запис без exact_anchor.");
}
if (acceptedRecords.length !== Object.keys(exactCitations).length) {
  errors.push(
    "Кількість accepted-записів не збігається з кількістю exact anchors: " +
      acceptedRecords.length + " != " + Object.keys(exactCitations).length + "."
  );
}

if (errors.length > 0) {
  console.error(errors.join("\n"));
  process.exit(1);
}

const document = {
  schema_version: "0.3",
  generated_from: "skills/tryascia/references/korpus-100.md",
  generated_by: "scripts/validate-corpus.mjs",
  record_count: records.length,
  accepted_record_count: acceptedRecords.length,
  candidate_record_count: candidateRecords.length,
  runtime_status: policy.default_runtime_status,
  runtime_records: acceptedRecords,
  records,
};

fs.writeFileSync(jsonPath, JSON.stringify(document, null, 2) + "\n", "utf8");
console.log(
  "OK: перевірено " + records.length +
    " записів; accepted=" + acceptedRecords.length +
    ", candidate=" + candidateRecords.length + "."
);
