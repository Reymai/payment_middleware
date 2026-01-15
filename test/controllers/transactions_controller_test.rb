require "test_helper"

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  # Scenario 1: Successful payment
  test "should authorize transaction and show success" do
    transaction_id = "123_abc"

    base_url = ProviderClient::BASE_URL

    # Stubbing the PUT request to the Provider (Success case)
    stub_request(:put, "#{base_url}/transactions/auth/#{transaction_id}")
      .to_return(
        status: 200,
        body: { status: "success" }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Act
    get "/transactions/auth/#{transaction_id}"

    # Assert
    assert_response :success # HTTP 200
    assert_equal "success", response.body
  end

  # Scenario 2: Failed payment
  test "should show failed when provider returns failure" do
    transaction_id = "999_error"

    base_url = ProviderClient::BASE_URL

    # Stubbing the PUT request (Failure case)
    stub_request(:put, "#{base_url}/transactions/auth/#{transaction_id}")
      .to_return(
        status: 200, # Provider might return 200 OK but with status: "failed" in body
        body: { status: "failed" }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Act
    get "/transactions/auth/#{transaction_id}"

    # Assert
    assert_response :unprocessable_entity # We chose HTTP 422 for failure
    assert_equal "failed", response.body
  end
end