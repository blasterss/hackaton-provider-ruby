# Настройка окружения

## Требования

- Ruby 3.4+;
- Bundler 2.6+;
- Git.
- `curl`;
- Ubuntu/Debian-пакеты для сборки Ruby.

ERB входит в стандартную библиотеку Ruby, отдельная установка шаблонизатора не
требуется.

## Системные зависимости Ubuntu/Debian

Установите пакеты, необходимые для сборки Ruby и работы rbenv:

```bash
sudo apt update
sudo apt install -y \
	autoconf bison build-essential curl git \
	libdb-dev libffi-dev libgdbm-dev libgdbm-compat-dev \
	libncurses-dev libreadline-dev libssl-dev \
	libyaml-dev rust zlib1g-dev
```

## Установка rbenv и Ruby

Установите `rbenv` и plugin `ruby-build` в домашний каталог:

```bash
git clone https://github.com/rbenv/rbenv.git "$HOME/.rbenv"
git clone https://github.com/rbenv/ruby-build.git "$HOME/.rbenv/plugins/ruby-build"

export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
eval "$(rbenv init - bash)"

rbenv install 3.4.10       # если версия ещё не установлена
rbenv local 3.4.10
```

Чтобы rbenv подключался автоматически в новых Bash-сессиях, добавьте в
`~/.bashrc`:

```bash
export PATH="$HOME/.rbenv/bin:$HOME/.rbenv/shims:$PATH"
eval "$(rbenv init - bash)"
```

Загрузите настройки текущей сессии:

```bash
source ~/.bashrc
```

Проверка:

```bash
rbenv --version
ruby --version
```

Ожидается Ruby 3.4.x:

```text
ruby 3.4.10 (2026-06-30 revision 2b0b7728dc) +PRISM [x86_64-linux]
```

## Установка зависимостей

```bash
gem install bundler -v '~> 2.6'
bundle install
```

Проверка Bundler и установленных гемов:

```bash
bundle --version
bundle check
```

Для чтения и валидации OpenAPI 3 используется open-source гем
`openapi3_parser`. Доступ к нему из приложения изолирован адаптером
`ProviderIntegrator::Parsers::Openapi`.

## Запуск генератора

Из корня репозитория:

```bash
./integrate --spec config/provider_api.yaml
```

Чтобы вывести промежуточную `Integration Model` как JSON без генерации файлов:

```bash
./integrate --spec config/provider_api.yaml --dump-model
```

## Форматирование Ruby

```bash
bundle exec rubocop -x  # исправить только форматирование
bundle exec rubocop     # проверить стиль
```
