# Source layout

```text
src/
├── lib/provider_integrator/
│   ├── parsers/       # YAML/OpenAPI → документ
│   ├── extractors/    # документ → факты интеграции
│   ├── model/         # промежуточная модель
│   ├── generators/    # service, documentation и fixture generators
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
integration = ProviderIntegrator.build("config/provider_api.yaml")
```

Полная генерация возвращает пути ко всем созданным артефактам:

```ruby
paths = ProviderIntegrator.generate(
  "config/provider_api.yaml",
  output_dir: "output"
)
# => ["output/novapay_service.rb", "output/INTEGRATION.md", "output/fixtures.json"]
```

Или вывести как JSON через CLI без записи выходных файлов:

```bash
./integrate --spec config/provider_api.yaml --dump-model
```
