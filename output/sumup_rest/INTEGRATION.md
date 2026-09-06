# SumUp REST Integration Guide

## Авторизация

- Тип: Bearer Token
- Header: `Authorization: Bearer <credentials.access_token>`
- Хранение: `providers.credentials` (encrypted)

## Методы

| Operation ID | Метод | Endpoint | Назначение | Idempotency |
|--------------|-------|----------|------------|-------------|
| CreateCheckout | POST | `/v0.1/checkouts` | Создание операции | — |
| GetMerchantMember | GET | `/v0.1/merchants/{merchant_code}/members/{member_id}` | Получение статуса | — |
| GetReader | GET | `/v0.1/merchants/{merchant_code}/readers/{reader_id}` | Получение статуса | — |
| GetReaderStatus | GET | `/v0.1/merchants/{merchant_code}/readers/{reader_id}/status` | Получение статуса | — |
| process_callback | POST | `/webhooks/readers.created` | Callback | — |

## Маппинг статусов

| Provider | Space Payments |
|----------|----------------|
| pending | in_progress |

## Обработка ошибок

| HTTP | Provider code | Internal code | Действие | Retryable |
|------|---------------|---------------|----------|-----------|
| 400 | — | validation_error | reject | нет |
| 401 | — | invalid_credentials | block | нет |
| 403 | — | provider_error | reject | нет |
| 404 | — | not_found | reject | нет |

## ProviderGateway config

Конфигурация ProviderGateway не определена в спецификации.

## Webhook signature

Проверка подписи webhook не определена в спецификации.

