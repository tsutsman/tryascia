#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";

const root = process.cwd();
const markdownPath = path.join(root, "skills/tryascia/references/korpus-100.md");
const jsonPath = path.join(root, "skills/tryascia/references/korpus.json");
const markdown = fs.readFileSync(markdownPath, "utf8");

const sourceUrls = {
  "С": "https://irbis-nbuv.gov.ua/ulib/item/UKR0001861",
  "Ф": "https://www.i-franko.name/uk/Folklore/1901/GalRusProverbs.html",
  "Н": "https://archive.org/details/nomis1864",
  "Г": "https://hrinchenko.com/",
  "К": "https://uk.wikisource.org/wiki/Твори_(Котляревський,_1922)/Том_1/Енеїда",
  "Л": "https://uk.wikisource.org/wiki/Кайдашева_сім’я"
};

const exactCitations = {
  "дідько": [
    {
      url: "https://www.i-franko.name/uk/Folklore/1901/GalRusProverbs/Items/Didko121-251.html",
      note: "Окремий розділ Франкового корпусу з численними народними формулами."
    }
  ],
  "біс": [
    {
      url: "https://www.i-franko.name/uk/Folklore/1901/GalRusProverbs/Items/Bis-Bovtaty.html",
      note: "Окремий розділ Франкового корпусу; є записи з Коломийщини."
    }
  ],
  "бісівщина": [
    {
      url: "https://www.i-franko.name/uk/Folklore/1901/GalRusProverbs/Items/Bis-Bovtaty.html",
      note: "Похідна сучасна форма; базову лексему «біс» зафіксовано окремим розділом."
    }
  ],
  "бодай": [
    {
      url: "https://www.i-franko.name/uk/Folklore/1901/GalRusProverbs/Items/Bogorodycja-Bolity.html",
      note: "Окремий розділ «Мудрування. Бодай» із народними формулами прокльону."
    }
  ],
  "щоб його качка копнула": [
    {
      url: "https://www.i-franko.name/uk/Folklore/1901/GalRusProverbs/Items/Kacap-Kypa.html",
      note: "Сторінка містить близькі народні варіанти «Бодай тебе качка надоптала!» та «Бодай тя качка копла!»."
    }
  ],
  "через пень-колоду": [
    {
      url: "https://www.i-franko.name/uk/Folklore/1901/GalRusProverbs/Items/Pacaniv-Pershyna.html",
      note: "Зафіксовано варіант «Через пень колоду валити»."
    }
  ]
};

const rowPattern = /^\|\s*(\d+)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*(\d+)\s*\|\s*([^|]+?)\s*\|\s*([ABC])\s*\|$/gm;
const rows = [...markdown.matchAll(rowPattern)].map((match) => ({
  id: Number(match[1]),
  form: match[2].trim(),
  meaning: match[3].trim(),
  intensity: Number(match[4]),
  layer: match[5].trim(),
  state: match[6]
}));

const errors = [];
const supportedSourceCodes = new Set(Object.keys(sourceUrls));
const forms = new Set();

if (rows.length !== 100) {
  errors.push("Очікувалося 100 записів, знайдено " + rows.length + ".");
}

for (const [index, row] of rows.entries()) {
  const expectedId = index + 1;
  if (row.id !== expectedId) {
    errors.push("Порушена нумерація біля запису " + row.id + "; очікувався " + expectedId + ".");
  }

  const normalizedForm = row.form.normalize("NFC").toLocaleLowerCase("uk-UA");
  if (forms.has(normalizedForm)) {
    errors.push("Дубль форми: " + row.form);
  }
  forms.add(normalizedForm);

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
  for (const code of sourceCodes) {
    if (!supportedSourceCodes.has(code)) {
      errors.push("Невідомий джерельний код у записі " + row.id + ": " + code);
    }
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
    exact_citations: citations,
    note: citations.length > 0
      ? "Є точна опорна сторінка; варіант форми може відрізнятися від оригінального написання."
      : "Кандидат: джерельний шар визначено, але точний запис або сторінку ще треба додати під час редакторської верифікації."
  };
});

const document = {
  schema_version: "0.2",
  generated_from: "skills/tryascia/references/korpus-100.md",
  generated_by: "scripts/validate-corpus.mjs",
  record_count: records.length,
  records
};

fs.writeFileSync(jsonPath, JSON.stringify(document, null, 2) + "\n", "utf8");
console.log("OK: перевірено " + records.length + " записів; JSON оновлено.");
