# Changelog

## Unreleased

### Додано

- first-class підтримку Hermes Agent через AgentSkills-сумісний skill та `install-hermes.sh`;
- first-class підтримку OpenClaw через managed/workspace skill та `install-openclaw.sh`;
- локальні й remote-ref smoke-перевірки для Hermes Agent та OpenClaw.

### Змінено

- CI перевіряє shell-синтаксис і інсталяцію для Codex, Claude Code, Hermes Agent та OpenClaw;
- README містить матрицю підтримуваних агентів і окремі інструкції встановлення.

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
