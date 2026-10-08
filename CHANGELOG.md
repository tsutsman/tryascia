# Changelog

## Unreleased

### Додано

- fixed-tag smoke для опублікованого `v1.1.0` на Codex, Claude Code, Hermes Agent та OpenClaw;
- end-to-end upgrade regression `v1.0.0 → v1.1.0` з повторною інсталяцією та uninstall без видалення unmanaged files;
- machine verification release assets `tryascia-1.1.0.tar.gz`, `SHA256SUMS` та `install-manifest.sha256`;
- `scripts/validate-stable-hardening.mjs`, який не дозволяє випасти post-release checks із required CI.

### Змінено

- `SECURITY.md` розширено до 4-agent installer/supply-chain disclosure та patch-response contract;
- `docs/RELEASING.md` документує post-release verification після публікації stable tag.

## 1.1.0 — 28.08.2026

### Додано

- `install-manifest.sha256` для SHA256-перевірки керованого install payload;
- спільні staging/verification primitives у `scripts/install-common.sh`;
- regression smoke для checksum mismatch і simulated download failure на Codex, Claude Code, Hermes Agent та OpenClaw;
- постійний `.github/workflows/release.yml` для stable/patch релізів із уже існуючих `vX.Y.Z` tags;
- детермінований release archive `tryascia-X.Y.Z.tar.gz`, `SHA256SUMS` та документований `docs/RELEASING.md`;
- `scripts/validate-release-pipeline.mjs` для машинної перевірки release/supply-chain контракту;
- `evals/behavior-policy.json` і `scripts/validate-behavior.mjs` для executable regression-gate public/security/irreversible/no-user-insult/intensity та `lite/full/ultra/normal`;
- `evals/candidate-decisions-1.1.json` з явним рішенням для кожного з 10 frozen candidates;
- 5 нових exact anchors у `evals/verified-anchors-1.1.json`;
- `evals/compatibility-contract.json`, `scripts/validate-compatibility.mjs`, `tests/compatibility-smoke.sh` і `docs/COMPATIBILITY.md` для формального contract Codex, Claude Code, Hermes Agent та OpenClaw.

### Змінено

- усі чотири інсталятори спочатку готують payload у тимчасовому каталозі, перевіряють checksum і лише після цього змінюють target;
- directory-based skill install використовує swap підготовленого дерева та зберігає сторонні файли;
- reinstall/uninstall smoke перевіряє ідемпотентність і видалення лише керованих ТРЯСЦЕЮ файлів;
- `npm test` перевіряє drift install manifest, release pipeline contract, behavioral policy та compatibility contract;
- GitHub Actions dependencies pinned на конкретні commit SHA, checkout не зберігає git credentials;
- release automation не створює/не рухає tags і не модифікує `main`: tag має вже існувати, мати stable semver, відповідати package/evals version і вказувати на commit з історії `main`;
- corpus quality gate піднято з 90/10 до 95 `accepted` / максимум 5 `candidate`;
- `ебашити`, `ебашить`, `ебанутися` замінено на джерельно зафіксовані `ібошити`, `ібошить`, `їбанутися`;
- `йобнулося` та `довбодятел` підвищено до `accepted` після exact-anchor перевірки;
- п’ять слабше підтверджених форм залишено `candidate` без послаблення стандарту;
- canonical `SKILL.md` синхронізовано з accepted runtime pool і явно підтримує `normal` mode;
- `main` захищено active ruleset `Hardening`: PR-only, required check `corpus`, deletion/force-push заблоковано, bypass відсутній;
- Wiki вимкнено, merged head branches видаляються автоматично;
- package/evals/README синхронізовано на stable `1.1.0`.

### Перевірки

- 100 records / 95 accepted / 5 candidate / 95 runtime;
- `npm test` з corpus/evals/manifests/release/behavior/compatibility gates;
- generated corpus drift;
- shell syntax;
- installer reinstall/uninstall та atomicity;
- Hermes `HERMES_HOME` / `HERMES_SKILLS_DIR` overrides;
- OpenClaw managed/workspace layout;
- remote-ref smoke для Codex, Claude Code, Hermes Agent та OpenClaw;
- protected `main` з required status check `corpus`.

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
- shell syntax;
- installer smoke;
- remote-ref smoke для 4 платформ.
