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
  "йой": [
    {
      url: "https://www.i-franko.name/uk/Folklore/1901/GalRusProverbs/Items/Aby-Ani.html",
      note: "У Франковому корпусі зафіксовано формулу «Або гой, або йой»; слово «йой» входить до дослівного запису."
    }
  ],
  "ой леле": [
    {
      url: "https://slovnyk.me/dict/synonyms_vusyk/%D0%BE%D0%B9",
      note: "Словникова стаття містить сполуку «ой, леле» як вигук."
    }
  ],
  "дідько": [
    {
      url: "https://www.i-franko.name/uk/Folklore/1901/GalRusProverbs/Items/Didko121-251.html",
      note: "Окремий розділ Франкового корпусу з численними народними формулами."
    }
  ],
  "дідько лисий": [
    {
      url: "https://www.i-franko.name/uk/Folklore/1901/GalRusProverbs/Items/Tatuno-Terpec.html",
      note: "У записі з Кукизова дослівно вжито сполуку «дідько лисий»."
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
  "бодай би": [
    {
      url: "https://www.i-franko.name/uk/Folklore/1901/GalRusProverbs/Items/Vorknuty-Vorona.html",
      note: "У Франковому записі дослівно вжито формулу «Бодай би того...»."
    }
  ],
  "хай йому грець": [
    {
      url: "https://slovnyk.me/dict/phraseology/%D1%85%D0%B0%D0%B9",
      note: "Фразеологічна стаття містить точну сполуку «хай йому грець»."
    }
  ],
  "до біса": [
    {
      url: "https://www.i-franko.name/uk/Prose/DomashnijPromysl.html",
      note: "У Франковому прозовому тексті дослівно вжито «Там до біса!»."
    }
  ],
  "щоб його качка копнула": [
    {
      url: "https://www.i-franko.name/uk/Folklore/1901/GalRusProverbs/Items/Kacap-Kypa.html",
      note: "Сторінка містить близькі народні варіанти «Бодай тебе качка надоптала!» та «Бодай тя качка копла!»."
    }
  ],
  "кат його знає": [
    {
      url: "https://www.i-franko.name/uk/Folklore/1901/GalRusProverbs/Items/Kamuz-Kateryna.html",
      note: "У записі з Нагуєвичів дослівно вжито «Кат його знає!»."
    }
  ],
  "щоб його грім побив": [
    {
      url: "https://www.i-franko.name/uk/Poems/KovalBassim/6.html",
      note: "У Франковому тексті зафіксовано близьку формулу «Ледарів щоб грім побив!»."
    }
  ],
  "лиха година": [
    {
      url: "https://www.i-franko.name/uk/Folklore/1901/GalRusProverbs/Items/Lyko-Lykho.html",
      note: "Франковий корпус містить дослівну сполуку «лиха година»."
    }
  ],
  "через пень-колоду": [
    {
      url: "https://www.i-franko.name/uk/Folklore/1901/GalRusProverbs/Items/Pacaniv-Pershyna.html",
      note: "Зафіксовано варіант «Через пень колоду валити»."
    }
  ],
  "дупа": [
    {
      url: "https://hrinchenko.com/dictionary/word/14380-dupa",
      note: "Словникова стаття Бориса Грінченка містить лексему «дупа» та її тлумачення."
    }
  ],
  "довбати": [
    {
      url: "https://hrinchenko.com/dictionary/word/12682-dovbati",
      note: "Словникова стаття Бориса Грінченка містить лексему «довбати»."
    }
  ],
  "довбатися": [
    {
      url: "https://hrinchenko.com/dictionary/word/12683-dovbatisia",
      note: "Словникова стаття Бориса Грінченка містить лексему «довбатися»."
    }
  ],
  "на живу нитку": [
    {
      url: "https://slovnyk.me/dict/phraseology/%D0%B6%D0%B8%D0%B2%D0%B8%D0%B9",
      note: "Фразеологічна стаття містить точну сполуку «на живу нитку»."
    }
  ],
  "як мокре горить": [
    {
      url: "https://i-franko.name/uk/Folklore/1901/GalRusProverbs/Items/Robyty.html",
      note: "У Франковому корпусі дослівно зафіксовано «Робит, як мокре горит»."
    }
  ],
  "ні руш": [
    {
      url: "https://i-franko.name/uk/Verses/IzLitMojejiMolodosti/NashiChesnoty/Patriotyzm.html",
      note: "У Франковому тексті дослівно вжито «Ні руш!»."
    }
  ],
  "якось воно буде": [
    {
      url: "https://www.i-franko.name/uk/Prose/LelIPolel/3.html",
      note: "У Франковій прозі дослівно вжито «Ну, ну, тихо, якось воно буде!»."
    }
  ],
  "чортівня": [
    {
      url: "https://goroh.pp.ua/%D0%A2%D0%BB%D1%83%D0%BC%D0%B0%D1%87%D0%B5%D0%BD%D0%BD%D1%8F/%D1%87%D0%BE%D1%80%D1%82%D1%96%D0%B2%D0%BD%D1%8F",
      note: "Тлумачний словник містить окрему статтю «чортівня»."
    }
  ],
  "морока": [
    {
      url: "https://hrinchenko.com/dictionary/word/29000-moroka",
      note: "Словникова стаття Бориса Грінченка містить лексему «морока» та формулу «Морока його знає»."
    }
  ],
  "халепа": [
    {
      url: "https://hrinchenko.com/dictionary/word/62371-xalepa",
      note: "Словникова стаття Бориса Грінченка містить лексему «халепа» та приклад «Нехай йому халепа»."
    }
  ],
  "влипнути": [
    {
      url: "https://slovnyk.me/amp/dict/vts/%D0%B2%D0%BB%D0%B8%D0%BF%D0%BD%D1%83%D1%82%D0%B8",
      note: "Тлумачний словник містить окрему статтю «влипнути»."
    }
  ],
  "горе-майстер": [
    {
      url: "https://goroh.pp.ua/%D0%A1%D0%BB%D0%BE%D0%B2%D0%BE%D0%B2%D0%B6%D0%B8%D0%B2%D0%B0%D0%BD%D0%BD%D1%8F/%D0%B3%D0%BE%D1%80%D0%B5-%D0%BC%D0%B0%D0%B9%D1%81%D1%82%D0%B5%D1%80",
      note: "Словник слововживання містить окрему статтю «горе-майстер»."
    }
  ],
  "телепень": [
    {
      url: "https://hrinchenko.com/dictionary/word/58216-telepen",
      note: "Словникова стаття Бориса Грінченка містить лексему «телепень»."
    }
  ],
  "йолоп": [
    {
      url: "https://hrinchenko.com/dictionary/word/21691-iolop",
      note: "Словникова стаття Бориса Грінченка містить лексему «йолоп»."
    }
  ],
  "бевзь": [
    {
      url: "https://hrinchenko.com/dictionary/word/1168-bevz",
      note: "Словникова стаття Бориса Грінченка містить лексему «бевзь» як лайливе слово."
    }
  ],
  "паскуда": [
    {
      url: "https://hrinchenko.com/dictionary/word/36822-paskuda",
      note: "Словникова стаття Бориса Грінченка подає «паскуда» як лайливе слово."
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
