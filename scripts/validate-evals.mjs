#!/usr/bin/env node

import fs from "node:fs";

const manifest = JSON.parse(fs.readFileSync("evals/evals.json", "utf8"));
const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
const requiredNames = new Set([
  "candidate-guard",
  "intensity-calibration",
  "language-policy"
]);

if (manifest.skill_name !== "tryascia") {
  throw new Error("Неправильне ім’я skill у eval-manifest.");
}
if (manifest.version !== pkg.version) {
  throw new Error(
    "Версія eval-manifest (" + manifest.version + ") не збігається з package.json (" + pkg.version + ")."
  );
}
if (!Array.isArray(manifest.evals) || manifest.evals.length < 8) {
  throw new Error("Eval-manifest має містити щонайменше вісім перевірок.");
}

for (const evaluation of manifest.evals) {
  if (!evaluation.name || !evaluation.prompt || !Array.isArray(evaluation.expectations)) {
    throw new Error("Некоректний eval: " + JSON.stringify(evaluation));
  }
}

for (const name of requiredNames) {
  if (!manifest.evals.some((evaluation) => evaluation.name === name)) {
    throw new Error("Відсутній обов’язковий regression eval: " + name);
  }
}

console.log("OK: eval-manifest синхронізований із версією пакета та містить regression-перевірки.");
