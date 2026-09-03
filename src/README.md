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
