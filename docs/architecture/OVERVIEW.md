# Архитектура генератора

Генератор строится как конвейер с промежуточной моделью. 

- [План действий генератора](../plans/ACTION_PLAN.md);
- [План разработки](../plans/DEVELOPMENT_PLAN.md).

```text
provider_api.yaml
       │
       ▼
    Parsers          чтение и базовая проверка OpenAPI
       │
       ▼
   Extractors        поиск auth, payout, status, webhook, ошибок
       │
       ▼
     Model           единое описание интеграции
       │
       ▼
   Generators        выбор артефактов и Ruby-блоков
       │
       ▼
    Renderers        рендер ERB
       │
       ├── provider_service.rb
       ├── INTEGRATION.md
       └── fixtures.json
```

## Текущий статус

Сейчас реализован минимальный сквозной запуск для Ruby-сервиса:

```text
CLI → OpenAPI Parser → Provider/Auth Extractors → Integration Model
    → Service Generator → ERB Renderer → <provider>_service.rb
```

Команда:

```bash
./integrate --spec config/provider_api.yaml
```

валидирует OpenAPI средствами `openapi3_parser`, вычисляет данные провайдера из
`info.title`, извлекает API key или bearer authentication, status endpoint и
маппинг известных статусов, после чего создаёт `output/novapay_service.rb`.
`slug` является вычисленным полем `Provider` и не передаётся через CLI.


## Слои

### Parsers

Читают YAML/OpenAPI и возвращают структуру документа. Здесь находится только синтаксическая проверка.

### Extractors

Извлекают из OpenAPI факты предметной области: способ авторизации, endpoint
создания выплаты, status endpoint, webhook, идемпотентность, ограничения суммы,
статусы и HTTP-ошибки. Эвристики должны жить здесь, а не в ERB.

### Model

Промежуточное представление интеграции. Оно должно отвечать на вопросы шаблона:
как называется класс, какой `BASE_URL`, какие публичные методы нужны, какие
маппинги и обработчики включить.

### Generators

Выбирают выходные артефакты и наборы блоков. Например, наличие API key включает
блок `authentication/api_key`, а наличие HMAC webhook - блок
`callbacks/hmac_sha256`.

### Renderers

Единственная ответственность - загрузить ERB, передать ему модель и вернуть
отрендеренный текст. Запись результата выполняет generator.

## ERB-шаблоны

`src/templates/ruby/service.rb.erb` задаёт каркас класса и точки вставки.
Переиспользуемые фрагменты лежат в `src/templates/ruby/blocks`. Блок должен быть
небольшим и отвечать за одну возможность.

Документация и JSON-фикстуры имеют отдельные корневые шаблоны. Они используют ту
же промежуточную модель, поэтому содержимое всех трёх артефактов остаётся
согласованным.

## Направление зависимостей

```text
CLI → Parser → Extractors → Model → Generators → Renderers → ERB
```

Зависимость в обратную сторону не допускается. В частности, модель не вызывает
parser, а шаблоны не ищут данные в исходном YAML.

## Первый вертикальный срез

Для первого рабочего сценария достаточно поддержать NovaPay:

1. API key из `X-API-Key`;
2. `POST /payouts` как `create_request`;
3. `GET /payouts/{payout_id}` как `fetch_status`;
4. HMAC-SHA256 webhook как `process_callback`;
5. minimum amount как `check_conditions`;
6. status/error maps;
7. генерацию сервиса, инструкции и фикстур из одной модели.
