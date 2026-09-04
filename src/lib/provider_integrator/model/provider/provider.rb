# frozen_string_literal: true

module ProviderIntegrator
  module Model
    # Идентификационные данные провайдера для имён и URL в шаблонах.
    #
    # - `name`:  отображаемое название, например `NovaPay`.
    # - `slug`: техническое имя для каталогов и файлов.
    # - `class_name`: часть имени генерируемого Ruby-класса.
    # - `base_url`: URL API, используемый по умолчанию.
    # - `base_url_env_name`: имя переменной окружения для переопределения URL.
    Provider = Data.define(
      :name,
      :slug,
      :class_name,
      :base_url,
      :base_url_env_name
    ) do
      include ValueObject
    end
  end
end
