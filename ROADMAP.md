# Roadmap ТРЯСЦІ

Після стабільного `v1.0.0` розвиток іде через сумісність, якість runtime-поведінки та supply-chain hardening. Нові форми не є самоціллю: джерельний стандарт не послаблюється заради кількості.

## Політика версій

- `1.0.x` — лише bugfix, security та compatibility fixes без зміни основного контракту.
- `1.1.0` — сумісні покращення інсталяторів, релізного процесу, evals, corpus quality і agent compatibility.
- Breaking changes відкладаються до окремого major-релізу.

## 1.1 — пріоритети

### P0 — governance

**#17 — Захистити `main` і зафіксувати governance.**

- branch protection / ruleset;
- required `Validate ТРЯСЦЯ / corpus`;
- заборона force-push і видалення `main`;
- automatic deletion merged head branches;
- перевірка repo metadata/settings.

Це блокер для нормального довгострокового maintenance, але не повинно блокувати підготовку кодових PR, якщо зміна repo settings потребує ручного доступу власника.

### P1 — installer та release hardening

**#18 — Атомарні й перевірювані інсталятори.**

- staging у `mktemp -d`;
- валідація payload до запису в target;
- checksum/manifest;
- regression tests для network/checksum failure;
- однаковий rollback-contract для Codex, Claude Code, Hermes Agent та OpenClaw.

**#19 — Стабільний release pipeline і supply-chain GitHub Actions.**

- постійний release workflow замість одноразових publisher-ів;
- release лише з clean tag/commit;
- SHA256 manifest для release payload;
- pin GitHub Actions до commit SHA;
- документований release/rollback flow для `1.0.x` і `1.1.0`.

### P1 — runtime quality

**#20 — Behavioral evals і corpus quality.**

- редакторське рішення для 10 frozen candidates;
- бажана ціль `>=95 accepted`, але без послаблення exact-anchor gate;
- машинні regression checks для public output, security clarity, no-user-insult, intensity calibration та `normal` mode;
- candidate ніколи не потрапляє до runtime pool без exact anchor.

### P2 — compatibility contract

**#21 — Формалізувати compatibility contract для 4 агентів.**

- fixtures для очікуваної структури install;
- перевірка AgentSkills-сумісного `SKILL.md`;
- окремі тести OpenClaw managed/workspace;
- окремі тести Hermes path overrides;
- update/reinstall/uninstall regression;
- support matrix: stable / experimental / unsupported.

## Definition of Done для `v1.1.0`

1. `main` governance підтверджений або P0 має явно задокументований зовнішній блокер.
2. Усі 4 stable інтеграції проходять local і remote-ref compatibility tests.
3. Інсталятор не залишає partial state після network/checksum failure.
4. Release pipeline створює реліз із чистого tag/commit і не модифікує `main`.
5. CI dependencies pinned до конкретних commit SHA.
6. Runtime corpus містить лише exact-anchor records; quality не погіршена відносно `v1.0.0`.
7. Boundary evals мають машинний regression gate.
8. `npm test`, generated drift, shell syntax, local smoke і remote-ref smoke зелені.
9. README/CHANGELOG/support matrix синхронізовані з фактичною поведінкою.

## Не входить у 1.1

- АБСУРД і стиль Леся Подерв’янського — окремий репозиторій;
- breaking зміни формату `SKILL.md` або installer contract;
- автоматичне підвищення candidate до accepted без джерельної опори;
- додавання платформ без тестованого install/runtime contract.
