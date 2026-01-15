class GatewayController < ApplicationController
  # Disable CSRF protection because this endpoint is an API called by an external Gateway
  skip_before_action :verify_authenticity_token

  # POST /gateway/transactions
  def create
    amount = params[:amount]
    currency = params[:currency]

    # Step 1: Call Provider to init transaction
    provider_response = ProviderClient.init_transaction(amount, currency)

    # Check if we got a valid ID (basic safety check)
    transaction_id = provider_response['transaction_id']

    if transaction_id.blank?
      render json: { error: 'Provider failed to initialize transaction' }, status: :bad_gateway
      return
    end

    # Step 2: Construct the redirect URL for our system.
    # Ideally, use Rails helpers: transactions_auth_url(transaction_id)
    # For now, we build it manually to match the task description explicitly.
    # Note: 'request.base_url' automatically gives us 'http://localhost:3000' or domain.
    redirect_url = "#{request.base_url}/transactions/auth/#{transaction_id}"

    # Step 3: Respond to Gateway
    render json: { redirect_url: redirect_url }
  end
end