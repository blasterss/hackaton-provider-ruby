# Paystack Integration Guide

## Авторизация

- Тип: Bearer Token
- Header: `Authorization: Bearer <credentials.access_token>`
- Хранение: `providers.credentials` (encrypted)

## Методы

| Operation ID | Метод | Endpoint | Назначение | Idempotency |
|--------------|-------|----------|------------|-------------|
| charge_create | POST | `/charge` | Создание операции | — |
| transaction_initialize | POST | `/transaction/initialize` | API endpoint | — |
| transaction_chargeAuthorization | POST | `/transaction/charge_authorization` | API endpoint | — |
| transaction_partialDebit | POST | `/transaction/partial_debit` | API endpoint | — |
| transaction_verify | GET | `/transaction/verify/{reference}` | Получение статуса | — |
| transaction_list | GET | `/transaction` | API endpoint | — |
| transaction_fetch | GET | `/transaction/{id}` | Получение статуса | — |
| transaction_timeline | GET | `/transaction/timeline/{id}` | Получение статуса | — |
| transaction_totals | GET | `/transaction/totals` | API endpoint | — |
| transaction_export | GET | `/transaction/export` | API endpoint | — |
| charge_submitPin | POST | `/charge/submit_pin` | API endpoint | — |
| charge_submitOtp | POST | `/charge/submit_otp` | API endpoint | — |
| charge_submitPhone | POST | `/charge/submit_phone` | API endpoint | — |
| charge_submitBirthday | POST | `/charge/submit_birthday` | API endpoint | — |
| charge_submitAddress | POST | `/charge/submit_address` | API endpoint | — |
| charge_check | GET | `/charge/{reference}` | Получение статуса | — |
| bulkCharge_list | GET | `/bulkcharge` | API endpoint | — |
| bulkCharge_initiate | POST | `/bulkcharge` | API endpoint | — |
| bulkCharge_fetch | GET | `/bulkcharge/{code}` | Получение статуса | — |
| bulkCharge_charges | GET | `/bulkcharge/{code}/charges` | Получение статуса | — |
| bulkCharge_pause | GET | `/bulkcharge/pause/{code}` | Получение статуса | — |
| bulkCharge_resume | GET | `/bulkcharge/resume/{code}` | Получение статуса | — |
| subaccount_list | GET | `/subaccount` | API endpoint | — |
| subaccount_create | POST | `/subaccount` | API endpoint | — |
| subaccount_fetch | GET | `/subaccount/{code}` | Получение статуса | — |
| subaccount_update | PUT | `/subaccount/{code}` | API endpoint | — |
| split_list | GET | `/split` | API endpoint | — |
| split_create | POST | `/split` | API endpoint | — |
| split_fetch | GET | `/split/{id}` | Получение статуса | — |
| split_update | PUT | `/split/{id}` | API endpoint | — |
| split_addSubaccount | POST | `/split/{id}/subaccount/add` | API endpoint | — |
| split_removeSubaccount | POST | `/split/{id}/subaccount/remove` | API endpoint | — |
| terminal_sendEvent | POST | `/terminal/{id}/event` | API endpoint | — |
| terminal_fetchEventStatus | GET | `/terminal/{terminal_id}/event/{event_id}` | Получение статуса | — |
| terminal_fetchTerminalStatus | GET | `/terminal/{terminal_id}/presence` | Получение статуса | — |
| terminal_list | GET | `/terminal` | API endpoint | — |
| terminal_fetch | GET | `/terminal/{terminal_id}` | Получение статуса | — |
| terminal_update | PUT | `/terminal/{terminal_id}` | API endpoint | — |
| terminal_commission | POST | `/terminal/commission_device` | API endpoint | — |
| terminal_decommission | POST | `/terminal/decommission_device` | API endpoint | — |
| virtualTerminal_list | GET | `/virtual_terminal` | API endpoint | — |
| virtualTerminal_create | POST | `/virtual_terminal` | API endpoint | — |
| virtualTerminal_fetch | GET | `/virtual_terminal/{code}` | Получение статуса | — |
| virtualTerminal_update | PUT | `/virtual_terminal/{code}` | API endpoint | — |
| virtualTerminal_deactivate | PUT | `/virtual_terminal/{code}/deactivate` | API endpoint | — |
| virtualTerminal_destinationAssign | POST | `/virtual_terminal/{code}/destination/assign` | API endpoint | — |
| virtualTerminal_destinationUnassign | POST | `/virtual_terminal/{code}/destination/unassign` | API endpoint | — |
| virtualTerminal_addSplitCode | PUT | `/virtual_terminal/{code}/split_code` | API endpoint | — |
| virtualTerminal_deleteSplitCode | DELETE | `/virtual_terminal/{code}/split_code` | API endpoint | — |
| customer_list | GET | `/customer` | API endpoint | — |
| customer_create | POST | `/customer` | API endpoint | — |
| customer_fetch | GET | `/customer/{code}` | Получение статуса | — |
| customer_update | PUT | `/customer/{code}` | API endpoint | — |
| customer_riskAction | POST | `/customer/set_risk_action` | API endpoint | — |
| customer_validate | POST | `/customer/{code}/identification` | API endpoint | — |
| customer_initializeAuthorization | POST | `/customer/authorization/initialize` | API endpoint | — |
| customer_verifyAuthorization | GET | `/customer/authorization/verify/{reference}` | Получение статуса | — |
| customer_deactivateAuthorization | POST | `/customer/authorization/deactivate` | API endpoint | — |
| customer_initializeDirectDebit | POST | `/customer/{id}/initialize-direct-debit` | API endpoint | — |
| customer_directDebitActivationCharge | PUT | `/customer/{id}/directdebit-activation-charge` | API endpoint | — |
| customer_fetchMandateAuthorizations | GET | `/customer/{id}/directdebit-mandate-authorizations` | Получение статуса | — |
| directdebit_triggerActivationCharge | PUT | `/directdebit/activation-charge` | API endpoint | — |
| directdebit_listMandateAuthorizations | GET | `/directdebit/mandate-authorizations` | API endpoint | — |
| dedicatedAccount_list | GET | `/dedicated_account` | API endpoint | — |
| dedicatedAccount_create | POST | `/dedicated_account` | API endpoint | — |
| dedicatedAccount_assign | POST | `/dedicated_account/assign` | API endpoint | — |
| dedicatedAccount_fetch | GET | `/dedicated_account/{id}` | Получение статуса | — |
| dedicatedAccount_deactivate | DELETE | `/dedicated_account/{id}` | API endpoint | — |
| dedicatedAccount_requery | GET | `/dedicated_account/requery` | API endpoint | — |
| dedicatedAccount_addSplit | POST | `/dedicated_account/split` | API endpoint | — |
| dedicatedAccount_removeSplit | DELETE | `/dedicated_account/split` | API endpoint | — |
| dedicatedAccount_availableProviders | GET | `/dedicated_account/available_providers` | API endpoint | — |
| applePay_listDomain | GET | `/apple-pay/domain` | API endpoint | — |
| applePay_registerDomain | POST | `/apple-pay/domain` | API endpoint | — |
| applePay_unregisterDomain | DELETE | `/apple-pay/domain` | API endpoint | — |
| plan_list | GET | `/plan` | API endpoint | — |
| plan_create | POST | `/plan` | API endpoint | — |
| plan_fetch | GET | `/plan/{code}` | Получение статуса | — |
| plan_update | PUT | `/plan/{code}` | API endpoint | — |
| subscription_list | GET | `/subscription` | API endpoint | — |
| subscription_create | POST | `/subscription` | API endpoint | — |
| subscription_fetch | GET | `/subscription/{code}` | Получение статуса | — |
| subscription_disable | POST | `/subscription/disable` | API endpoint | — |
| subscription_enable | POST | `/subscription/enable` | API endpoint | — |
| subscription_manageLink | GET | `/subscription/{code}/manage/link` | Получение статуса | — |
| subscription_manageEmail | POST | `/subscription/{code}/manage/email` | API endpoint | — |
| transferrecipient_list | GET | `/transferrecipient` | API endpoint | — |
| transferrecipient_create | POST | `/transferrecipient` | API endpoint | — |
| transferrecipient_bulk | POST | `/transferrecipient/bulk` | API endpoint | — |
| transferrecipient_fetch | GET | `/transferrecipient/{code}` | Получение статуса | — |
| transferrecipient_update | PUT | `/transferrecipient/{code}` | API endpoint | — |
| transferrecipient_delete | DELETE | `/transferrecipient/{code}` | API endpoint | — |
| transfer_list | GET | `/transfer` | API endpoint | — |
| transfer_initiate | POST | `/transfer` | API endpoint | — |
| transfer_finalize | POST | `/transfer/finalize_transfer` | API endpoint | — |
| transfer_bulk | POST | `/transfer/bulk` | API endpoint | — |
| transfer_fetch | GET | `/transfer/{code}` | Получение статуса | — |
| transfer_verify | GET | `/transfer/verify/{reference}` | Получение статуса | — |
| transfer_exportTransfer | GET | `/transfer/export` | API endpoint | — |
| transfer_resendOtp | POST | `/transfer/resend_otp` | API endpoint | — |
| transfer_disableOtp | POST | `/transfer/disable_otp` | API endpoint | — |
| transfer_disableOtpFinalize | POST | `/transfer/disable_otp_finalize` | API endpoint | — |
| transfer_enableOtp | POST | `/transfer/enable_otp` | API endpoint | — |
| balance_fetch | GET | `/balance` | Получение баланса | — |
| balance_ledger | GET | `/balance/ledger` | Получение баланса | — |
| paymentRequest_list | GET | `/paymentrequest` | API endpoint | — |
| paymentRequest_create | POST | `/paymentrequest` | API endpoint | — |
| paymentRequest_fetch | GET | `/paymentrequest/{id}` | Получение статуса | — |
| paymentRequest_update | PUT | `/paymentrequest/{id}` | API endpoint | — |
| paymentRequest_verify | GET | `/paymentrequest/verify/{id}` | Получение статуса | — |
| paymentRequest_notify | POST | `/paymentrequest/notify/{id}` | API endpoint | — |
| paymentRequest_totals | GET | `/paymentrequest/totals` | API endpoint | — |
| paymentRequest_finalize | POST | `/paymentrequest/finalize/{id}` | API endpoint | — |
| paymentRequest_archive | POST | `/paymentrequest/archive/{id}` | API endpoint | — |
| product_list | GET | `/product` | API endpoint | — |
| product_create | POST | `/product` | API endpoint | — |
| product_fetch | GET | `/product/{id}` | Получение статуса | — |
| product_update | PUT | `/product/{id}` | API endpoint | — |
| product_delete | DELETE | `/product/{id}` | API endpoint | — |
| storefront_list | GET | `/storefront` | API endpoint | — |
| storefront_create | POST | `/storefront` | API endpoint | — |
| storefront_fetch | GET | `/storefront/{id}` | Получение статуса | — |
| storefront_update | PUT | `/storefront/{id}` | API endpoint | — |
| storefront_delete | DELETE | `/storefront/{id}` | API endpoint | — |
| storefront_verifySlug | GET | `/storefront/verify/{slug}` | Получение статуса | — |
| storefront_fetchOrders | GET | `/storefront/{id}/order` | Получение статуса | — |
| storefront_listProducts | GET | `/storefront/{id}/product` | Получение статуса | — |
| storefront_addProducts | POST | `/storefront/{id}/product` | API endpoint | — |
| storefront_publish | POST | `/storefront/{id}/publish` | API endpoint | — |
| storefront_duplicate | POST | `/storefront/{id}/duplicate` | API endpoint | — |
| order_list | GET | `/order` | API endpoint | — |
| order_create | POST | `/order` | API endpoint | — |
| order_fetch | GET | `/order/{id}` | Получение статуса | — |
| order_product | GET | `/order/product/{id}` | Получение статуса | — |
| order_validate | GET | `/order/{code}/validate` | Получение статуса | — |
| page_list | GET | `/page` | API endpoint | — |
| page_create | POST | `/page` | API endpoint | — |
| page_fetch | GET | `/page/{id}` | Получение статуса | — |
| page_update | PUT | `/page/{id}` | API endpoint | — |
| page_checkSlugAvailability | GET | `/page/check_slug_availability/{slug}` | Получение статуса | — |
| page_addProducts | POST | `/page/{id}/product` | API endpoint | — |
| settlements_fetch | GET | `/settlement` | API endpoint | — |
| settlements_transaction | GET | `/settlement/{id}/transactions` | Получение статуса | — |
| integration_fetchPaymentSessionTimeout | GET | `/integration/payment_session_timeout` | API endpoint | — |
| integration_updatePaymentSessionTimeout | PUT | `/integration/payment_session_timeout` | API endpoint | — |
| refund_list | GET | `/refund` | API endpoint | — |
| refund_create | POST | `/refund` | API endpoint | — |
| refund_retry | POST | `/refund/retry_with_customer_details/{id}` | API endpoint | — |
| refund_fetch | GET | `/refund/{id}` | Получение статуса | — |
| dispute_list | GET | `/dispute` | API endpoint | — |
| dispute_fetch | GET | `/dispute/{id}` | Получение статуса | — |
| dispute_update | PUT | `/dispute/{id}` | API endpoint | — |
| dispute_uploadUrl | GET | `/dispute/{id}/upload_url` | Получение статуса | — |
| dispute_download | GET | `/dispute/export` | API endpoint | — |
| dispute_transaction | GET | `/dispute/transaction/{id}` | Получение статуса | — |
| dispute_resolve | PUT | `/dispute/{id}/resolve` | API endpoint | — |
| dispute_evidence | POST | `/dispute/{id}/evidence` | API endpoint | — |
| bank_list | GET | `/bank` | API endpoint | — |
| bank_resolveAccountNumber | GET | `/bank/resolve` | API endpoint | — |
| bank_validateAccountNumber | POST | `/bank/validate` | API endpoint | — |
| miscellaneous_resolveCardBin | GET | `/decision/bin/{bin}` | Получение статуса | — |
| miscellaneous_listCountries | GET | `/country` | API endpoint | — |
| miscellaneous_avs | GET | `/address_verification/states` | API endpoint | — |

## Маппинг статусов

Маппинг статусов не определён в спецификации.

## Обработка ошибок

| HTTP | Provider code | Internal code | Действие | Retryable |
|------|---------------|---------------|----------|-----------|
| 401 | — | invalid_credentials | block | нет |
| 400 | — | validation_error | reject | нет |
| 404 | — | not_found | reject | нет |
| 422 | — | validation_error | reject | нет |

## ProviderGateway config

Конфигурация ProviderGateway не определена в спецификации.

## Webhook signature

Webhook не определён в спецификации.

