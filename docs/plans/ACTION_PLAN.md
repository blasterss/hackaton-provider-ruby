# План действий генератора

Этот документ описывает поведение готового инструмента при одном запуске CLI.

```mermaid
flowchart TD
    start([Запуск integrate]) --> args[Чтение CLI-аргументов]
    args --> input[Загрузка provider_api.yaml]
    input --> syntax{OpenAPI синтаксически корректен?}

    syntax -- Нет --> parse_error[Отчёт об ошибках спецификации]
    parse_error --> failed([Завершение с ошибкой])

    syntax -- Да --> parse[Парсинг OpenAPI и разрешение ссылок]
    parse --> extract[Извлечение auth, endpoints, webhook, ошибок и ограничений]
    extract --> model[Построение Integration Model]
    model --> contract{Данных достаточно для контракта?}

    contract -- Нет --> warnings[Список отсутствующих или неоднозначных данных]
    warnings --> failed

    contract -- Да --> blocks[Выбор ERB-блоков]
    blocks --> service[Рендер Ruby-сервиса]
    blocks --> guide[Рендер INTEGRATION.md]
    blocks --> fixtures[Рендер fixtures.json]

    service --> validate[Проверка выходных файлов]
    guide --> validate
    fixtures --> validate

    validate --> valid{Результат валиден?}
    valid -- Нет --> generation_error[Отчёт об ошибках генерации]
    generation_error --> failed
    valid -- Да --> output[Запись файлов в output/provider]
    output --> done([Успешное завершение])
```

## Результат запуска

```text
output/<provider>/
├── <provider>_service.rb
├── INTEGRATION.md
└── fixtures.json
```

Генератор должен завершаться с ненулевым кодом, если входной OpenAPI нельзя
прочитать, промежуточная модель не удовлетворяет контракту или выходные файлы
не проходят проверку.
