# frozen_string_literal: true

module ProviderIntegrator
  # Internal Space Payments mapping kept outside provider OpenAPI documents.
  module ProviderGatewayRegistry
    CONFIGS = {
      "novapay" => {
        external_method: "sbp_payout",
        gateway: "RUB_SBP_WITHDRAW"
      }
    }.freeze

    module_function

    def fetch(provider_slug)
      values = CONFIGS[provider_slug]
      return unless values

      Model::GatewayConfig.new(**values)
    end
  end
end
