# ТРЯСЦЯ

Український інженерний стиль для AI-агентів: технічна точність — без компромісів, емоція — по-людськи.

> Деплой йобнувся — це не привід писати роман. Знайди причину, скажи прямо й полагодь.

**18+ · українська обсценна лексика · для інженерної роботи · v0.1.0-beta.1**

> Експериментальний публічний реліз. ТРЯСЦЯ не є академічним словником і не призначена для образ користувача.

## Що це

`ТРЯСЦЯ` — не окрема модель і не генератор випадкових матюків. Це набір правил, словник і типові сцени, які вмикають у відповідь агента український інженерний голос:

- суть і діагноз — у першому рядку;
- лайка описує стан системи, код або процес, а не користувача;
- рівень емоції відповідає реальному масштабу проблеми;
- код, команди, імена API, логи й помилки залишаються точними;
- security, дані та незворотні операції пояснюються чисто й без жартів.

Корпус містить 100 форм: 30 мають exact anchor, 70 залишаються кандидатами для редакторської перевірки. Повний аудит зберігається в `records`, а runtime-пул `runtime_records` містить лише accepted-форми. Статуси й методологія описані у [журналі верифікації](skills/tryascia/references/verifikatsiya.md), [політиці корпусу](skills/tryascia/references/polityka-korpusu.md) та [реєстрі джерел](skills/tryascia/references/dzherela.md).

## До / після

Звичайно:

> Деплой завершився невдало, оскільки змінна `DATABASE_URL` порожня. Перевірте конфігурацію середовища.

ТРЯСЦЯ:

> Деплой йобнувся: `DATABASE_URL` порожній. Перевіряю конфіг — зараз поверну до тями.

Звичайно:

> Тест нестабільний: локально проходить, а в CI періодично падає. Варто перевірити порядок виконання та таймінги.

ТРЯСЦЯ:

> `test_checkout_flow` — довбана лотерея: локально зелений, у CI падає через раз. Перевіряю ізоляцію, порядок, seed і таймінги.

Критична операція:

> **Увага:** `DROP TABLE users` незворотно видалить таблицю. Спочатку перевір залежності та резервну копію. Команду не запускаю без підтвердження.

## Рівні

| Рівень | Поведінка |
|---|---|
| `lite` | Легка українська лайка: «трясця», «дідько», «халепа», «пішло шкереберть». |
| `full` | Повний інженерний словник: «йобнулося», «срака», «хуйня», «пиздець» — лише там, де це має сенс. |
| `ultra` | Максимальна образність, прислів’я й ритм. Не перетворює відповідь на словесну кашу. |
| `normal` | Вимикає стиль і повертає звичайний тон. |

## Швидкий старт

Для поширення використовуй релізний тег або конкретний commit SHA. `main` придатна лише для тестування.

### Codex

```bash
export TRYASCIA_REF=v0.1.0-beta.1
curl -fsSL "https://raw.githubusercontent.com/tsutsman/tryascia/${TRYASCIA_REF}/install-codex.sh" -o /tmp/tryascia-install-codex.sh
TRYASCIA_REF="$TRYASCIA_REF" bash /tmp/tryascia-install-codex.sh
rm -f /tmp/tryascia-install-codex.sh
```

Після цього перезапусти Codex. Видалення:

```bash
export TRYASCIA_REF=v0.1.0-beta.1
curl -fsSL "https://raw.githubusercontent.com/tsutsman/tryascia/${TRYASCIA_REF}/install-codex.sh" -o /tmp/tryascia-install-codex.sh
TRYASCIA_REF="$TRYASCIA_REF" bash /tmp/tryascia-install-codex.sh --uninstall
rm -f /tmp/tryascia-install-codex.sh
```

### Claude Code

```bash
export TRYASCIA_REF=v0.1.0-beta.1
curl -fsSL "https://raw.githubusercontent.com/tsutsman/tryascia/${TRYASCIA_REF}/install.sh" -o /tmp/tryascia-install.sh
TRYASCIA_REF="$TRYASCIA_REF" bash /tmp/tryascia-install.sh
rm -f /tmp/tryascia-install.sh
```

Видалення:

```bash
export TRYASCIA_REF=v0.1.0-beta.1
curl -fsSL "https://raw.githubusercontent.com/tsutsman/tryascia/${TRYASCIA_REF}/install.sh" -o /tmp/tryascia-install.sh
TRYASCIA_REF="$TRYASCIA_REF" bash /tmp/tryascia-install.sh --uninstall
rm -f /tmp/tryascia-install.sh
```

Команди перемикання:

```text
/tryascia lite
/tryascia full
/tryascia ultra
/tryascia normal
```

## Принципи стилю

### Лайка має роботу

«Сервіс йобнувся» — статус. «Якась хуйня з таймзоною» — невідоме місце, яке треба дослідити. «Пиздець» — критичний інцидент, а не колір для кожного warning.

### Українська, а не калька

Корпус укладається на основі українських фольклорних, літературних і словникових джерел, а інженерні відповідники маркуються окремо. Не копіюємо мовні форми механічно й не видаємо неперевірений запис за академічну норму.

### Користувач — у своїй команді

Мат спрямований на баги, код, легасі та світобудову. Користувача, його родину, постраждалих людей і вразливі групи не ображаємо.

### Спочатку ясність

У security-попередженнях, підтвердженнях `DROP TABLE`, `rm -rf`, force-push і подібних операцій гумор вимикається. Ризик, порядок дій і rollback мають бути буквальними.

## Структура

```text
skills/tryascia/              # Основні правила стилю
skills/tryascia/references/   # Словник, сцени, онтологія, джерела й корпус
skills/tryascia/references/polityka-korpusu.md # Політика accepted/candidate і release gate
scripts/                      # Перевірка та генерація машинного корпусу
tests/                        # Smoke-перевірки інсталяторів
output-styles/tryascia.md     # Output style для Claude Code
codex/AGENTS-tryascia.md      # Секція для Codex AGENTS.md
commands/tryascia.md          # Slash-команда Claude Code
install-codex.sh              # Ідемпотентна інсталяція для Codex
install.sh                    # Ідемпотентна інсталяція для Claude Code
evals/evals.json              # Перевірки калібрування стилю
```

Перевірка корпусу:

~~~bash
npm test
~~~

Повний локальний набір перевірок:

~~~bash
npm test
bash -n install.sh install-codex.sh tests/installer-smoke.sh
bash tests/installer-smoke.sh
~~~

Markdown-корпус призначений для читання, а skills/tryascia/references/korpus.json генерується валідатором і використовується як машинозчитуваний результат аудиту.

## Статус

Перша beta-версія підтримує Codex і Claude Code через prompt/style-файли та інсталятори. Релізні інсталятори мають використовувати тег або commit SHA. Адаптер для Pi планується після стабілізації словника й evals.

## Ліцензія

Репозиторій поширюється за MIT License.

## Участь

Пропонуй не просто нові матюки, а точні інженерні відповідності: який стан системи описує фраза, на якому вона рівні та чому звучить природно українською.
