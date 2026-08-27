# Compatibility contract

**Contract schema:** `1.0` · **Release track:** Unreleased `1.1`

ТРЯСЦЯ має один canonical runtime skill: `skills/tryascia/SKILL.md` + `skills/tryascia/references/`. Платформні адаптери не мають власних копій корпусу.

Машинним джерелом істини є `evals/compatibility-contract.json`; `scripts/validate-compatibility.mjs` і `tests/compatibility-smoke.sh` блокують непомітні breaking-зміни layout, installer overrides або runtime contract.

## Рівні підтримки

| Рівень | Значення |
|---|---|
| `stable` | Входить до CI, local/reinstall/uninstall smoke та remote-ref release contract. Breaking layout change потребує явного оновлення fixture. |
| `experimental` | Може змінюватися без compatibility guarantee; не входить до stable release contract. |
| `unsupported` | Не тестується й не заявляється як підтримувана інтеграція. |

## Матриця

| Агент | Статус | Installer | Runtime/layout | Platform overrides |
|---|---|---|---|---|
| Codex | `stable` | `install-codex.sh` | керований блок у `AGENTS.md` + `tryascia/references/` | `TARGET_CODEX_DIR` |
| Claude Code | `stable` | `install.sh` | `output-styles/tryascia.md` + canonical `skills/tryascia/` | `TARGET_CLAUDE_DIR` |
| Hermes Agent | `stable` | `install-hermes.sh` | AgentSkills `SKILL.md` у `<skills>/tryascia` | `HERMES_HOME`, `HERMES_SKILLS_DIR`, `TARGET_HERMES_SKILL_DIR` |
| OpenClaw | `stable` | `install-openclaw.sh` | AgentSkills `SKILL.md`; managed або workspace install | `OPENCLAW_STATE_DIR`, `OPENCLAW_SKILLS_DIR`, `TARGET_OPENCLAW_SKILL_DIR` |

Інші інтеграції, яких немає в `evals/compatibility-contract.json`, вважаються `unsupported`, доки окремий PR не додасть adapter, fixtures і CI-перевірки.

## Спільний release-ref contract

Усі чотири stable installer-и використовують `TRYASCIA_REF`. Для поширення слід передавати stable tag або конкретний commit SHA; `main` використовується для розробки/тестування.

Compatibility contract не дозволяє окремому адаптеру мовчки перейти на інший release-ref механізм.

## AgentSkills invariant

Hermes Agent і OpenClaw використовують один і той самий `skills/tryascia/SKILL.md`. CI перевіряє YAML frontmatter (`name: tryascia`, `description`) і відсутність platform-specific дубльованих skill-дерев.

`SKILL.md` не може використовувати `candidate` або замінені форми як runtime-приклади.

## Що перевіряє CI

- чотири й лише чотири заявлені stable інтеграції;
- `TRYASCIA_REF` у кожному installer;
- platform-specific env overrides;
- canonical repository files та відсутність дубльованих platform skill trees;
- `SKILL.md` frontmatter і runtime examples лише з accepted corpus;
- Codex/Claude explicit target layout;
- Hermes `HERMES_HOME` і `HERMES_SKILLS_DIR`;
- OpenClaw managed mode через `OPENCLAW_STATE_DIR`;
- OpenClaw workspace mode через `OPENCLAW_SKILLS_DIR`;
- reinstall/update/uninstall для кожного stable adapter;
- remote-ref smoke окремим загальним release test.

Якщо installer або layout змінюється навмисно, PR має одночасно оновити `evals/compatibility-contract.json`, відповідний smoke fixture і документацію.
