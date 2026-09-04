# Настройка окружения

## Требования

- Ruby 3.4+;
- Bundler 2.6+;
- Git.

ERB входит в стандартную библиотеку Ruby, отдельная установка шаблонизатора не
требуется.

## Установка Ruby через rbenv

Если `rbenv` уже установлен в домашнем каталоге:

```bash
export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
eval "$(rbenv init - bash)"
rbenv install 3.4.10       # если версия ещё не установлена
rbenv local 3.4.10
```

Проверка:

```bash
ruby --version
bundle --version
```

## Установка зависимостей

```bash
bundle install
```

Для чтения и валидации OpenAPI 3 используется open-source гем
`openapi3_parser`. Доступ к нему из приложения изолирован адаптером
`ProviderIntegrator::Parsers::Openapi`.

## Запуск генератора

Из корня репозитория:

```bash
./integrate --spec config/provider_api.yaml
```

## Форматирование Ruby

```bash
bundle exec rubocop -x  # исправить только форматирование
bundle exec rubocop     # проверить стиль
```
