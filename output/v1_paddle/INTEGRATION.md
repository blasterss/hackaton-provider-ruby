# v1: Paddle Integration Guide

## Авторизация

- Тип: Bearer Token
- Header: `Authorization: Bearer <credentials.access_token>`
- Хранение: `providers.credentials` (encrypted)

## Методы

| Operation ID | Метод | Endpoint | Назначение | Idempotency |
|--------------|-------|----------|------------|-------------|
| create-transaction | POST | `/transactions` | Создание операции | — |
| list-products | GET | `/products` | API endpoint | — |
| create-product | POST | `/products` | API endpoint | — |
| get-product | GET | `/products/{product_id}` | API endpoint | — |
| update-product | PATCH | `/products/{product_id}` | API endpoint | — |
| list-prices | GET | `/prices` | API endpoint | — |
| create-price | POST | `/prices` | API endpoint | — |
| get-price | GET | `/prices/{price_id}` | API endpoint | — |
| update-price | PATCH | `/prices/{price_id}` | API endpoint | — |
| list-transactions | GET | `/transactions` | API endpoint | — |
| price-preview | POST | `/pricing-preview` | API endpoint | — |
| preview-transaction | POST | `/transactions/preview` | API endpoint | — |
| get-transaction | GET | `/transactions/{transaction_id}` | Получение статуса | — |
| update-transaction | PATCH | `/transactions/{transaction_id}` | API endpoint | — |
| list-adjustments | GET | `/adjustments` | API endpoint | — |
| create-adjustment | POST | `/adjustments` | API endpoint | — |
| list-credit-balances | GET | `/customers/{customer_id}/credit-balances` | Получение баланса | — |
| list-customers | GET | `/customers` | API endpoint | — |
| create-customer | POST | `/customers` | API endpoint | — |
| get-customer | GET | `/customers/{customer_id}` | API endpoint | — |
| update-customer | PATCH | `/customers/{customer_id}` | API endpoint | — |
| list-addresses | GET | `/customers/{customer_id}/addresses` | API endpoint | — |
| create-address | POST | `/customers/{customer_id}/addresses` | API endpoint | — |
| get-address | GET | `/customers/{customer_id}/addresses/{address_id}` | API endpoint | — |
| update-address | PATCH | `/customers/{customer_id}/addresses/{address_id}` | API endpoint | — |
| list-businesses | GET | `/customers/{customer_id}/businesses` | API endpoint | — |
| create-business | POST | `/customers/{customer_id}/businesses` | API endpoint | — |
| get-business | GET | `/customers/{customer_id}/businesses/{business_id}` | API endpoint | — |
| update-business | PATCH | `/customers/{customer_id}/businesses/{business_id}` | API endpoint | — |
| list-notification-settings | GET | `/notification-settings` | API endpoint | — |
| create-notification-setting | POST | `/notification-settings` | API endpoint | — |
| get-notification-setting | GET | `/notification-settings/{notification_setting_id}` | API endpoint | — |
| update-notification-setting | PATCH | `/notification-settings/{notification_setting_id}` | API endpoint | — |
| delete-notification-setting | DELETE | `/notification-settings/{notification_setting_id}` | API endpoint | — |
| list-event-types | GET | `/event-types` | API endpoint | — |
| list-events | GET | `/events` | API endpoint | — |
| list-notifications | GET | `/notifications` | API endpoint | — |
| get-notification | GET | `/notifications/{notification_id}` | API endpoint | — |
| list-notification-logs | GET | `/notifications/{notification_id}/logs` | API endpoint | — |
| replay-notification | POST | `/notifications/{notification_id}/replay` | API endpoint | — |
| get-ip-addresses | GET | `/ips` | API endpoint | — |
| get-transaction-invoice | GET | `/transactions/{transaction_id}/invoice` | API endpoint | — |
| list-discounts | GET | `/discounts` | API endpoint | — |
| create-discount | POST | `/discounts` | API endpoint | — |
| get-discount | GET | `/discounts/{discount_id}` | API endpoint | — |
| update-discount | PATCH | `/discounts/{discount_id}` | API endpoint | — |
| get-subscription | GET | `/subscriptions/{subscription_id}` | API endpoint | — |
| update-subscription | PATCH | `/subscriptions/{subscription_id}` | API endpoint | — |
| list-subscriptions | GET | `/subscriptions` | API endpoint | — |
| cancel-subscription | POST | `/subscriptions/{subscription_id}/cancel` | Отмена операции | — |
| pause-subscription | POST | `/subscriptions/{subscription_id}/pause` | API endpoint | — |
| resume-subscription | POST | `/subscriptions/{subscription_id}/resume` | API endpoint | — |
| activate-subscription | POST | `/subscriptions/{subscription_id}/activate` | API endpoint | — |
| get-subscription-update-payment-method-transaction | GET | `/subscriptions/{subscription_id}/update-payment-method-transaction` | API endpoint | — |
| preview-subscription | PATCH | `/subscriptions/{subscription_id}/preview` | API endpoint | — |
| create-subscription-charge | POST | `/subscriptions/{subscription_id}/charge` | API endpoint | — |
| preview-subscription-charge | POST | `/subscriptions/{subscription_id}/charge/preview` | API endpoint | — |
| list-reports | GET | `/reports` | API endpoint | — |
| create-report | POST | `/reports` | API endpoint | — |
| get-report-csv | GET | `/reports/{report_id}/download-url` | API endpoint | — |
| get-report | GET | `/reports/{report_id}` | API endpoint | — |

## Маппинг статусов

| Provider | Space Payments |
|----------|----------------|
| draft | in_progress |
| ready | in_progress |
| billed | in_progress |
| paid | approved |
| completed | approved |
| canceled | rejected |
| past_due | rejected |

## Обработка ошибок

Правила обработки ошибок не определены в спецификации.

## ProviderGateway config

Конфигурация ProviderGateway не определена в спецификации.

## Webhook signature

Webhook не определён в спецификации.

