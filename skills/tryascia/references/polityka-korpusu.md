# Політика корпусу

Корпус ТРЯСЦІ має два різні призначення: редакторський аудит і runtime-використання агентом.

## Статуси

- `accepted` — форма має `exact_anchor` і може використовуватися у звичайному режимі;
- `candidate` — джерельний напрям визначено, але точного підтвердження ще недостатньо.

`candidate` не є помилкою, але не є й доказом усталеності форми. Кандидат не можна подавати як дослівну цитату або академічну норму.

## Runtime-правило

Файл `skills/tryascia/references/korpus.json` зберігає повний аудит у полі `records`, але поле `runtime_records` містить лише `accepted`-форми. Саме runtime-пул використовується за замовчуванням.

Інженерна адаптація може пояснювати значення форми, але не підвищує її джерельний статус.

## Release gate

Машинним джерелом істини для числових порогів є `evals/corpus-policy.json`.

Для лінії `1.1` перевіряються:

1. щонайменше 95 `accepted`-записів;
2. не більше 5 `candidate`-записів у поточному корпусі;
3. кожен `accepted`-запис має `exact_anchor`;
4. кількість `accepted` збігається з кількістю exact anchors;
5. усі 10 frozen candidates із `v1.0.0` мають явне рішення `promote`, `replace` або `retain` у `evals/candidate-decisions-1.1.json`;
6. regression-evals не дозволяють видавати кандидата за підтверджену форму;
7. `evals/behavior-policy.json` машинно перевіряє public-output, security, irreversible-operation, no-user-insult, intensity calibration і режими `lite/full/ultra/normal`;
8. candidate ніколи не потрапляє до `runtime_records`;
9. інсталятори Codex, Claude Code, Hermes Agent і OpenClaw проходять локальні та remote-ref smoke-перевірки.

Історичний gate `v1.0.0` був 90 `accepted` / 10 `candidate`; файл `evals/v1-candidate-freeze.json` зберігається як вихідний список редакторського проходу 1.1.
