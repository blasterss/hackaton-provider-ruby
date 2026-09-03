# Полное описание

Space Payments подключает новых платёжных провайдеров регулярно. Каждая интеграция - Ruby-сервис с единым контрактом:

```rb
class Provider::ExampleService < Provider::BaseService
  def check_conditions(operation, request_method)   # предпроверки
  def create_request(operation, ...)                # создание выплаты/депозита
  def process_callback(payload)                     # обработка webhook
  def fetch_status(operation)                       # статус-запрос
end
```

Сейчас разработчик вручную читает документацию провайдера и пишет сервис с нуля. Это занимает 2–5 дней на интеграцию.
Задача: создать инструмент, который принимает открытую документацию API провайдера и генерирует интеграцию провайдера.


## Вводные данные

```
provider_api.yaml
```
Пример текстового файла с инструкцией, как программе обращаться к платежному провайдеру: куда отправлять запросы, какие данные передавать и какие ответы ожидать. 


## Ожидаемый результат

```rb
class Provider
  class NovapayService < BaseService
    BASE_URL = ENV.fetch('NOVAPAY_BASE_URL', 'https://api.sandbox.novapay.example/v1')


    def create_request(operation, request_method = 'create')
      payload = build_payout_payload(operation)
      response = client.post("#{BASE_URL}/payouts", json: payload, headers: auth_headers)
      parse_create_response(operation, response)
    rescue Provider::RateLimitError
      failure(:too_many_requests, 'provider.rate_limit')
    rescue Provider::UnauthorizedError
      failure(:unauthorized, 'provider.invalid_credentials')
    end


    def fetch_status(operation)
      response = client.get("#{BASE_URL}/payouts/#{operation.provider_operation_id}")
      map_status(response.body['status'])
    end


    def process_callback(payload)
      verify_signature!(payload) # HMAC-SHA256 из X-NovaPay-Signature


      case payload['event']
      when 'payout.completed' then approve_operation(payload['payout_id'])
      when 'payout.failed'    then reject_operation(payload['payout_id'], payload.dig('error', 'code'))
      else failure(:unprocessable_entity, 'unknown_event')
      end
    end


    def check_conditions(operation, request_method)
      base_result = super
      return base_result if base_result.failed?


      return failure(:unprocessable_entity, 'amount_too_low') if operation.amount < 1000
      success
    end


    private


    def build_payout_payload(operation)
      {
        amount: (operation.amount * 100).to_i,
        currency: 'RUB',
        external_id: operation.id,
        recipient: {
          type: 'sbp',
          phone: operation.payout_requisite.dig('sbp', 'phone'),
          bank_code: operation.payout_requisite.dig('sbp', 'bank_code'),
          bank_name: operation.payout_requisite.dig('sbp', 'bank_name')
        }
      }
    end


    STATUS_MAP = {
      'pending'    => 'in_progress',
      'processing' => 'in_progress',
      'completed'  => 'approved',
      'failed'     => 'rejected',
      'cancelled'  => 'rejected'
    }.freeze


    ERROR_MAP = {
      400 => 'validation_error',
      401 => 'invalid_credentials',
      402 => 'insufficient_balance',
      422 => 'validation_error',
      429 => 'rate_limit',
      500 => 'internal_error'
    }.freeze
  end
end
```


## Пример документации

```md
# NovaPay Integration Guide


## Авторизация
- Тип: API Key
- Header: `X-API-Key: <credentials.api_key>`
- Хранение: `providers.credentials` (encrypted)


## Методы
| Метод | Endpoint | Назначение | Idempotency |
|-------|----------|------------|-------------|
| create_payout | POST /payouts | Создание выплаты | Idempotency-Key header |
| get_status | GET /payouts/{id} | Статус | - |
| cancel | POST /payouts/{id}/cancel | Отмена | - |
| webhook | POST /webhooks/payout | Callback | X-NovaPay-Signature |


## Маппинг статусов
| Provider | Space Payments |
|----------|----------------|
| pending | in_progress |
| processing | in_progress |
| completed | approved |
| failed | rejected |
| cancelled | rejected |


## Обработка ошибок
| HTTP | Provider code | Действие |
|------|---------------|----------|
| 400 | validation_error | reject |
| 401 | unauthorized | alert ops, block provider |
| 402 | insufficient_balance | retry later |
| 429 | rate_limit_exceeded | retry with backoff |
| 500 | internal_error | retry, alert ops |


## ProviderGateway config
{ "external_method": "sbp_payout", "gateway": "RUB_SBP_WITHDRAW" }


## Webhook signature
HMAC-SHA256(body, callback_secret) → hex → X-NovaPay-Signature
```


## Тестовые фикстуры 

```json
{
  "create_request": {
    "request": {
      "amount": 1500000,
      "currency": "RUB",
      "external_id": "op_abc123",
      "recipient": { "type": "sbp", "phone": "79001234567", "bank_code": "044525225" }
    },
    "response_201": { "id": "np_7f3a9b2c", "status": "pending" },
    "response_422": { "error": { "code": "validation_error", "message": "Amount must be at least 100000 kopecks" } }
  },
  "fetch_status": {
    "response_200": { "id": "np_7f3a9b2c", "status": "completed" }
  },
  "callback": {
    "payload": { "event": "payout.completed", "payout_id": "np_7f3a9b2c", "status": "completed" },
    "expected_operation_status": "approved"
  },
  "callback_failed": {
    "payload": { "event": "payout.failed", "payout_id": "np_7f3a9b2c", "status": "failed", "error": { "code": "recipient_not_found" } },
    "expected_operation_status": "rejected"
  }
}
```

## CLI

```bash
$ ./integrate --spec provider_api.yaml


Parsing spec...
Found 5 endpoints: POST /payouts, GET /payouts/{id}, POST /payouts/{id}/cancel,
                  POST /webhooks/payout, GET /balance
Auth: ApiKeyAuth (header: X-API-Key)
Webhook signature: X-NovaPay-Signature (HMAC-SHA256)
Generating service...
Generating integration guide...
Generating test fixtures...


Output:
  ./output/novapay_service.rb
  ./output/INTEGRATION.md
  ./output/fixtures.json
```


## Ограничения

1) На кейсе нельзя использовать проприетарные технологии и решения с закрытым исходным кодом;
2) Большинство кода внутри репозитория должно быть написано на ruby;
3) Запрещено использование нейросетей внутри проекта.
