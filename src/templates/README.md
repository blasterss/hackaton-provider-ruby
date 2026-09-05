# Templates

Корневые ERB-шаблоны описывают структуру трёх выходных файлов:

```text
templates/
├── ruby/
│   ├── service.rb.erb
│   └── blocks/
├── documentation/
│   ├── integration.md.erb
│   └── sections/
└── fixtures/
    └── fixtures.json.erb
```

Ruby-шаблон и руководство собираются из небольших блоков, выбранных generator
по Integration Model. Шаблон фикстур детерминированно сериализует `FixtureSet`.
