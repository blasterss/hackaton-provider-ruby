# Source layout

```text
src/
├── lib/provider_integrator/
│   ├── parsers/       # YAML/OpenAPI → документ
│   ├── extractors/    # документ → факты интеграции
│   ├── model/         # промежуточная модель
│   ├── generators/    # выбор артефактов и блоков
│   └── renderers/     # ERB → файлы
└── templates/
    ├── ruby/
    │   ├── service.rb.erb
    │   └── blocks/
    ├── documentation/
    └── fixtures/
```

Модели сгруппированы по назначению:

```text
model/
├── integration.rb
├── value_object.rb
├── provider/          # provider, authentication, gateway config
├── operation/         # HTTP operation, параметры, поля и ответы
├── webhook/           # callback, подпись и события
├── rules/             # условия и статусы
└── support/           # fixtures и diagnostics
```

Модель можно построить отдельно от генерации:

```ruby
integration = ProviderIntegrator.build("../config/provider_api.yaml")
```

Или вывести как JSON через CLI без записи выходных файлов:

```bash
./integrate --spec config/provider_api.yaml --dump-model
```
