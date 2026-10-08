# Roadmap ТРЯСЦІ

ТРЯСЦЯ розвивається через сумісність, вимірювану runtime-поведінку та якість джерельної бази. Нові форми й нові платформи не є самоціллю: стабільний контракт і перевірюваність важливіші за кількість.

## Політика версій

- `1.0.x` — bugfix/security/compatibility fixes без зміни основного контракту.
- `1.1.x` — stabilization fixes поверх stable `v1.1.0`, без breaking змін `SKILL.md`/installer contract.
- `1.2.0` — сумісні покращення behavioral evals, CLI/diagnostics, upstream compatibility monitoring і corpus provenance.
- `1.3.x` — потенційний distribution/ecosystem цикл після стабілізації 1.2.
- Breaking changes відкладаються до окремого major-релізу і мають мати реальну contract-причину.

## 1.1 — завершено

Stable `v1.1.0` випущений. Задачі #17–#21 закриті як completed.

### Виконаний контракт 1.1

- protected `main`: PR-only, required `corpus`, force-push/delete blocked;
- атомарні checksum-verified installers;
- постійний deterministic release pipeline;
- 95 `accepted` / 5 `candidate` без послаблення exact-anchor gate;
- executable behavioral policy regression gate;
- stable compatibility contract для Codex, Claude Code, Hermes Agent та OpenClaw;
- release assets із SHA256 checksums.

## 1.2 — активний roadmap

Мета 1.2 — перейти від «репозиторій зі skill-файлами» до стабільного продуктового contract для AI-агентів: вимірювана поведінка, одна точка діагностики, автоматичне виявлення upstream regressions і формалізована provenance-якість корпусу.

### P0 — stabilization

**#30 — Post-release hardening для `v1.1.x`. — DONE**

- fixed-tag smoke опублікованого `v1.1.0` для 4 stable integrations;
- end-to-end upgrade `v1.0.0 → v1.1.0`;
- reinstall/update/uninstall після upgrade без втрати unmanaged files;
- machine verification release assets/checksums;
- 4-agent installer/supply-chain `SECURITY.md`;
- stable-hardening validator у required `corpus` CI.

P0 stabilization contract завершений; наступний основний блок — behavioral measurement.

### P1 — behavioral quality

**#31 — Live behavioral eval harness.**

- versioned scenario fixtures;
- provider-neutral result/schema contract;
- scoring: technical correctness, profanity targeting, intensity, Ukrainian naturalness, safety-context cleanliness, mode compliance;
- deterministic evals у PR CI;
- live-provider evals окремо від обов'язкового PR gate;
- baseline/regression comparison між релізами.

Ціль — вимірювати фактичну поведінку, а не лише структуру policy.

### P1 — product UX

**#32 — Unified CLI і `tryascia doctor`.**

- одна точка install/update/uninstall/diagnostics для 4 stable integrations;
- `tryascia doctor` показує version/ref, detected platform, target, manifest/checksum і canonical payload state;
- чинні shell installers лишаються supported compatibility backend у 1.2;
- CLI не дублює corpus/policy;
- documented machine-friendly exit codes.

### P1 — upstream compatibility

**#33 — Scheduled upstream compatibility matrix.**

- scheduled + manual compatibility run;
- current supported install/discovery/update/uninstall contract для 4 integrations;
- machine-readable report/artifact;
- platform-specific regression evidence;
- upstream instability не робить звичайний PR CI недетермінованим;
- compatibility status змінюється тільки через review/PR.

### P2 — corpus quality/provenance

**#34 — Corpus provenance grades і contribution workflow.**

- machine-readable provenance grade/state для всіх records;
- proposed levels A/B/C/D: академічне/словникове → література/фольклор → незалежні сучасні exact usages → candidate;
- grade не замінює `accepted/candidate` status;
- contribution template з source/exact quote/URL/context/intensity;
- pipeline: proposal → candidate → evidence → editorial decision → exact anchor → accepted → runtime;
- ніякого auto-promotion candidate.

## Рекомендований порядок виконання

1. **#31** — побудувати behavioral measurement contract.
2. **#32** — дати користувачу unified CLI/doctor поверх стабільного backend.
3. **#33** — винести upstream monitoring у scheduled compatibility layer.
4. **#34** — формалізувати provenance/contribution flow без гонитви за кількістю.

#31, #33 і #34 технічно можуть розвиватися незалежно. #32 тепер може будуватися поверх стабілізованого `v1.1.x` backend без rewrite installer contract.

## Definition of Done для `v1.2.0`

1. Немає відомих P0/P1 дефектів у stable install/update/uninstall path 4 integrations.
2. Upgrade `v1.0.0 → v1.1.x/1.2.0` покритий end-to-end regression tests.
3. Behavioral suite має versioned fixtures, machine-readable results і regression baseline.
4. Deterministic behavioral checks входять у PR CI; live-provider checks не роблять PR залежним від зовнішнього API.
5. `tryascia doctor` працює для Codex, Claude Code, Hermes Agent та OpenClaw.
6. Unified CLI не дублює canonical corpus/policy і не ламає shell installers.
7. Scheduled upstream compatibility matrix покриває всі 4 stable integrations і не модифікує `main`/tags/releases.
8. Усі 100 corpus records мають explicit provenance state/grade; 95/5 quality boundary не погіршена без нового evidence.
9. Candidate ніколи не потрапляє в runtime автоматично.
10. `npm test`, generated drift, shell syntax, installer atomicity, compatibility, upgrade і remote-ref/release-tag smoke зелені.
11. README/CHANGELOG/support matrix/CLI docs синхронізовані з фактичною поведінкою.
12. `v1.1.0` лишається immutable; breaking зміни не маскуються під 1.2.

## Не входить у 1.2

- АБСУРД і стиль Леся Подерв’янського — окремий репозиторій;
- breaking rewrite `SKILL.md` або installer contract;
- автоматичне підвищення candidate до accepted;
- додавання нових платформ без окремого tested compatibility contract;
- збільшення corpus заради числового KPI;
- окрема LLM/бот-модель «ТРЯСЦЯ».

## Горизонт після 1.2

Якщо 1.2 доведе CLI + behavioral measurement + provenance contract, наступний сумісний цикл може фокусуватися на distribution/ecosystem: компактний release bundle, простіший install UX, package distribution і зовнішні contribution workflows. `2.0.0` потрібен лише тоді, коли з'явиться обґрунтована breaking-причина.
