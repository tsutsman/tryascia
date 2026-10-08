# Безпека

ТРЯСЦЯ містить інсталятори для Codex, Claude Code, Hermes Agent та OpenClaw. Вони записують керований payload у каталоги агентів, тому installer/supply-chain дефекти розглядаються як security-sensitive.

## Підтримувані версії

- актуальний stable release і поточна patch-лінія отримують security/compatibility fixes;
- опубліковані release tags є незмінними: уразливий tag не переноситься на інший commit;
- дефект у release payload виправляється новим patch release через PR → CI → verified tag.

## Безпечне встановлення

Перед запуском інсталятора:

- використовуй stable release tag або конкретний commit SHA, не довільний mutable ref;
- перевір `install-manifest.sha256` і, для release archive, `SHA256SUMS`;
- переглянь target/override змінні (`TARGET_CODEX_DIR`, `TARGET_CLAUDE_DIR`, `TARGET_HERMES_SKILL_DIR`, `TARGET_OPENCLAW_SKILL_DIR`, `HERMES_HOME`, `HERMES_SKILLS_DIR`);
- не передавай у команди API keys, паролі чи інші секрети;
- для перевірки використовуй окремий тимчасовий каталог.

Інсталятори мають staging/checksum/atomicity contract і не повинні залишати partial managed state після checksum/network failure. Uninstall має видаляти тільки керовані ТРЯСЦЕЮ файли.

## Повідомлення про проблему

Не публікуй у відкритих issues exploit details, секрети або дані, які дають змогу змінювати чужі файли. Для приватного повідомлення використовуй GitHub Security Advisories репозиторію або інший приватний канал зв’язку з підтримувачем.

У повідомленні вкажи:

1. уражену версію/tag/commit і платформу;
2. уражений installer/workflow/file;
3. передумови та мінімальний спосіб відтворення;
4. фактичний вплив;
5. чи стосується проблема checksum, path traversal, overwrite/uninstall, release assets або credential exposure;
6. безпечний proof-of-concept без реальних секретів.

Не публікуй proof-of-concept до появи виправлення, якщо він дозволяє перезапис файлів, підміну release payload або витік credentials.

## Response policy

Після підтвердження проблеми підтримувач визначає affected releases, готує fix через захищений PR/CI flow і, за потреби, випускає новий patch. Існуючий tag не переписується; release може бути позначений/прихований як проблемний, але історія git не ретаргетується.

Цей документ описує процес повідомлення й response contract, а не гарантує відсутність уразливостей.
