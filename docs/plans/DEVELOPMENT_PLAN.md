# План разработки

Диаграмма показывает зависимости между компонентами. 

```mermaid
flowchart LR
    foundation["0. Структура проекта<br/>и ERB-каталоги"]
    model["1. Integration Model<br/>единый контракт данных"]
    parser["2. OpenAPI Parser<br/>YAML и refs"]
    extractors["3. Extractors<br/>правила и эвристики"]
    renderer["4. ERB Renderer<br/>контекст и partials"]
    blocks["5. Ruby-блоки<br/>NovaPay vertical slice"]
    generators["6. Generators<br/>service, docs, fixtures"]
    cli["7. CLI<br/>валидация и вывод"]
    release["8. Готовый MVP<br/>демо NovaPay"]

    foundation --> model
    model --> parser
    parser --> extractors
    model --> renderer
    renderer --> blocks
    extractors --> generators
    blocks --> generators
    generators --> cli
    cli --> release

    classDef done fill:#d1fae5,stroke:#047857,color:#064e3b
    classDef next fill:#fef3c7,stroke:#d97706,color:#78350f
    classDef pending fill:#f3f4f6,stroke:#6b7280,color:#111827

    class foundation,model,parser,renderer done
    class extractors,blocks,generators,cli next
    class release pending
```

## Текущий этап

Минимальный путь от CLI до Ruby-файла работает. Он предназначен для проверки
границ слоёв и пока генерирует сервис с методами-заготовками.

## Этапы

- [x] Подготовить каталоги слоёв и ERB-шаблонов.
- [x] Описать `Integration` и вложенные value objects.
- [x] Реализовать классы `Integration Model`.
- [ ] Реализовать проверку инвариантов модели.
- [x] Подключить `openapi3_parser` через собственный parser adapter.
- [x] Извлечь provider metadata и authentication в промежуточную модель.
- [ ] Извлечь данные NovaPay в промежуточную модель.
- [x] Реализовать базовый ERB renderer и подключение partial-блоков.
- [ ] Добавить блоки `create_request`, `fetch_status`, callback и mappings.
- [x] Собрать минимальный generator Ruby-сервиса.
- [ ] Собрать генераторы сервиса, документации и фикстур.
- [x] Подключить минимальный CLI с `--spec`, `--output` и кодами завершения.
- [ ] Добавить проверку полноты модели и подробные diagnostics в CLI.
- [ ] Проверить полный сценарий на `config/provider_api.yaml`.

## Критерий готовности MVP

Одна CLI-команда читает тестовый OpenAPI и детерминированно создаёт три валидных
артефакта. Повторный запуск с тем же входом не меняет результат, а неподдержанные
или неоднозначные части спецификации выводятся как явные ошибки или warnings.
