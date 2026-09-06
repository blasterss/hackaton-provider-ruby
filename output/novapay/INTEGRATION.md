# NovaPay Integration Guide

## Авторизация

- Тип: API Key
- Header: `X-API-Key: <credentials.api_key>`
- Хранение: `providers.credentials` (encrypted)

## Методы

| Operation ID | Метод | Endpoint | Назначение | Idempotency |
|--------------|-------|----------|------------|-------------|
| createPayout | POST | `/payouts` | Создание операции | Idempotency-Key header |
| getPayoutStatus | GET | `/payouts/{payout_id}` | Получение статуса | — |
| cancelPayout | POST | `/payouts/{payout_id}/cancel` | Отмена операции | — |
| getBalance | GET | `/balance` | Получение баланса | — |
| process_callback | POST | `/webhooks/payout` | Callback | X-NovaPay-Signature |

## Маппинг статусов

| Provider | Space Payments |
|----------|----------------|
| pending | in_progress |
| processing | in_progress |
| completed | approved |
| failed | rejected |
| cancelled | rejected |

## Обработка ошибок

| HTTP | Provider code | Internal code | Действие | Retryable |
|------|---------------|---------------|----------|-----------|
| 400 | — | validation_error | reject | нет |
| 401 | unauthorized | invalid_credentials | block | нет |
| 402 | insufficient_balance | insufficient_balance | retry | да |
| 422 | validation_error | validation_error | reject | нет |
| 429 | rate_limit_exceeded | rate_limit | retry | да |
| 500 | — | internal_error | retry | да |
| 404 | not_found | not_found | reject | нет |
| 409 | invalid_status | invalid_status | reject | нет |

## ProviderGateway config

```json
{"external_method":"sbp_payout","gateway":"RUB_SBP_WITHDRAW"}
```

## Webhook signature

`HMAC-SHA256(body, callback_secret) → hex → X-NovaPay-Signature`

