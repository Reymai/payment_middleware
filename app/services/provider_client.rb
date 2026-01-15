class ProviderClient
  class ProviderError < StandardError; end

  BASE_URL = ENV.fetch("PROVIDER_URL")

  # 1. Initiates a transaction with the external Provider.
  # Returns a Hash containing `transaction_id` and `status`.
  def self.init_transaction(amount, currency)
    conn = Faraday.new(url: BASE_URL) do |f|
      f.request :json
      f.response :json
    end

    response = conn.post("/transactions/init") do |req|
      req.body = { amount: amount, currency: currency }
    end

    unless response.success?
      error_msg = response.body['error'] || "HTTP #{response.status}"
      raise ProviderError, "Provider failed: #{error_msg}"
    end

    response.body
  rescue Faraday::ConnectionFailed => e
    # Если интернет отвалился или URL неправильный
    raise ProviderError, "Connection failed: #{e.message}"
  end

  # 2. Authorizes the transaction on the Provider side.
  # Returns a Hash containing the final `status`.
  def self.authorize_transaction(transaction_id)
    conn = Faraday.new(url: BASE_URL) do |f|
      f.request :json
      f.response :json
    end

    response = conn.put("/transactions/auth/#{transaction_id}")
    response.body
  end
end
