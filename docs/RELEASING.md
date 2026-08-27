# Релізи ТРЯСЦІ

Цей документ описує stable/patch release flow для `1.0.x` і `1.1.x`.

## Принцип

Release workflow **не створює, не рухає і не переписує теги** та не змінює `main`. Він публікує реліз лише з уже існуючого stable tag формату `vX.Y.Z`.

## Перед тегом

1. Усі зміни мають бути злиті в `main` через PR.
2. `package.json` і `evals/evals.json` мають містити однакову версію `X.Y.Z`.
3. README/CHANGELOG та installer refs мають бути синхронізовані з релізом.
4. `Validate ТРЯСЦЯ / corpus` має бути зеленим на release commit.
5. Release commit не повинен містити тимчасових publisher/cleanup workflows.

## Публікація

Створи stable tag `vX.Y.Z` **на перевіреному commit у `main`**. Push цього тега запускає `.github/workflows/release.yml`.

Workflow перевіряє:

- ім'я тега відповідає `^vX.Y.Z$` без prerelease suffix;
- commit тега входить в історію `main`;
- tag version = `package.json` version = `evals/evals.json` version;
- `npm test` проходить без generated/manifest drift;
- робоче дерево після валідації чисте;
- `tests/release-ref-smoke.sh` проходить через сам release tag для Codex, Claude Code, Hermes Agent та OpenClaw.

Після цього workflow створює детермінований `tryascia-X.Y.Z.tar.gz` через `git archive | gzip -n`, генерує `SHA256SUMS` і додає до GitHub Release:

- `tryascia-X.Y.Z.tar.gz`;
- `SHA256SUMS`;
- `install-manifest.sha256`.

Release створюється як stable (`draft=false`, `prerelease=false`).

## Повторний запуск

Якщо release job обірвався після створення тега, не рухай тег. Запусти workflow вручну (`workflow_dispatch`) і передай той самий existing tag. Якщо GitHub Release уже існує, workflow перевірить stable flags і перезавантажить checksum/assets із `--clobber`.

## Rollback

Тег після публікації вважається незмінним.

- Якщо помилка лише в GitHub Release assets/notes — виправ pipeline і повторно запусти workflow для того самого тега.
- Якщо дефект у коді/installer payload — не переписуй release tag. Зроби fix через PR і випусти наступний patch (`vX.Y.(Z+1)`).
- Якщо реліз треба приховати через критичну проблему, GitHub Release можна видалити/прибрати з публічної видачі, але tag не переноситься на інший commit.

## Supply-chain contract

- зовнішні GitHub Actions у workflow pinned на повні commit SHA;
- checkout не зберігає write credentials у git config (`persist-credentials: false`);
- release job має `contents: write` лише для GitHub Release assets;
- installer payload перевіряється окремим `install-manifest.sha256`;
- `scripts/validate-release-pipeline.mjs` не дозволяє повернути mutable Action refs або release workflow, що сам модифікує git refs/main.
