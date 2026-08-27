# Changelog

## Unreleased

### Додано

- `install-manifest.sha256` для SHA256-перевірки керованого install payload;
- спільні staging/verification primitives у `scripts/install-common.sh`;
- regression smoke для checksum mismatch і simulated download failure на Codex, Claude Code, Hermes Agent та OpenClaw.

### Змінено

- усі чотири інсталятори спочатку готують payload у тимчасовому каталозі, перевіряють checksum і лише після цього змінюють target;
- directory-based skill install використовує swap підготовленого дерева та зберігає сторонні файли;
- reinstall/uninstall smoke перевіряє ідемпотентність і видалення лише керованих ТРЯСЦЕЮ файлів;
- `npm test` перевіряє drift install manifest.

## 1.0.0 — 21.08.2026

### Додано

- 15 нових перевірених exact anchors у окремому V1-наборі;
- явний freeze 10 форм, які залишаються `candidate` до сильнішої джерельної опори.

### Змінено

- verified runtime-корпус розширено з 75 до 90 `accepted` форм;
- stable release gate піднято до 90 `accepted` / максимум 10 `candidate`;
- політику корпусу та журнал верифікації синхронізовано зі stable-рівнем;
- версію package та eval-manifest піднято до `1.0.0`;
- README та installer examples переведено на `v1.0.0`;
- підтримка Codex, Claude Code, Hermes Agent і OpenClaw входить до стабільного контракту релізу.

### Перевірки

- `npm test`;
- узгодженість версій `package.json` та `evals/evals.json`;
- generated corpus drift;
- 100 записів / 90 accepted / 10 candidate / 90 runtime records;
- shell syntax для всіх чотирьох інсталяторів;
- локальні installer smoke для Codex, Claude Code, Hermes Agent та OpenClaw;
- remote-ref installer smoke для всіх чотирьох платформ.

## 0.1.0-rc.2 — 19.08.2026

### Додано

- first-class підтримку Hermes Agent через AgentSkills-сумісний skill та `install-hermes.sh`;
- first-class підтримку OpenClaw через managed/workspace skill та `install-openclaw.sh`;
- локальні й remote-ref smoke-перевірки для Hermes Agent та OpenClaw.

### Змінено

- CI перевіряє shell-синтаксис і інсталяцію для Codex, Claude Code, Hermes Agent та OpenClaw;
- README містить матрицю підтримуваних агентів і окремі інструкції встановлення;
- версію пакета, eval-manifest і release refs синхронізовано на `0.1.0-rc.2`.

### Перевірки

- `npm test`;
- узгодженість версій `package.json` та `evals/evals.json`;
- generated corpus drift;
- 100 записів / 75 accepted / 25 candidate / 75 runtime records;
- shell syntax для всіх чотирьох інсталяторів;
- локальні installer smoke для Codex, Claude Code, Hermes Agent та OpenClaw;
- remote-ref installer smoke для всіх чотирьох платформ.

## 0.1.0-rc.1 — 18.08.2026

### Додано

- 25 нових перевірених exact anchors у окремому RC-наборі;
- boundary-evals для public-output cleanliness, security auto-clarity, no-user-insult і `normal` mode isolation.

### Змінено

- верифікований runtime-корпус розширено з 50 до 75 `accepted` форм;
- release gate піднято до 75 `accepted` / максимум 25 `candidate`;
- політику корпусу та журнал верифікації синхронізовано з RC-рівнем;
- валідатор читає base, beta.3 і rc.1 набори exact anchors як окремі дані.

### Перевірки

- `npm test`;
- узгодженість версій `package.json` та `evals/evals.json`;
- generated corpus drift;
- 100 записів / 75 accepted / 25 candidate / 75 runtime records;
- синтаксична перевірка shell-скриптів;
- локальна smoke-перевірка інсталяторів;
- smoke-перевірка інсталяторів через віддалений ref.

## 0.1.0-beta.3 — 18.08.2026

### Змінено

- верифікований runtime-корпус розширено з 30 до 50 `accepted` форм;
- release gate піднято до 50 `accepted` / максимум 50 `candidate`;
- exact anchors винесено з валідатора у структуровані JSON-файли даних;
- валідатор перевіряє дублікати anchors, URL, відповідність форм корпусу та узгодженість accepted-лічильника;
- посилено детермінованість generated corpus і перевірку drift у CI.

### Перевірки

- `npm test`;
- узгодженість версій `package.json` та `evals/evals.json`;
- generated corpus drift;
- синтаксична перевірка shell-скриптів;
- локальна smoke-перевірка інсталяторів;
- smoke-перевірка інсталяторів через віддалений ref.

## 0.1.0-beta.2 — 18.08.2026

### Додано

- політику корпусу зі статусами `accepted` і `candidate`;
- release gate для мінімальної кількості підтверджених форм;
- окремий runtime-пул лише з підтверджених записів;
- regression-evals для кандидатів, інтенсивності та мовної політики;
- smoke-перевірку встановлення з гілки, тега або commit ref.

### Змінено

- версію пакета оновлено до `0.1.0-beta.2`;
- README тепер використовує beta-релізний ref у прикладах;
- інсталяторні перевірки розділено на локальний режим і режим віддаленого ref.

### Перевірки

- `npm test`;
- синтаксична перевірка shell-скриптів;
- локальна smoke-перевірка інсталяторів;
- smoke-перевірка інсталяторів через віддалений ref.
