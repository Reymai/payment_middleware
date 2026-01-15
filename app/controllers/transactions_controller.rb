class TransactionsController < ApplicationController
  # GET /transactions/auth/:id
  def auth
    transaction_id = params[:id]

    # 1. Call the Provider to authorize the transaction
    # We reuse our Service Object
    provider_response = ProviderClient.authorize_transaction(transaction_id)

    # 2. Check the status from the Provider's response
    status = provider_response["status"]

    if status == "success"
      render plain: "success", status: :ok
    else
      render plain: "failed", status: :unprocessable_entity
    end
  end
end
