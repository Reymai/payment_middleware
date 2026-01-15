require "test_helper"

class GatewayControllerTest < ActionDispatch::IntegrationTest
  test "should initialize transaction and return redirect_url" do
    # 1. Arrange: Define the input data
    payload = { amount: 1000, currency: "EUR", id: "unique id" }

    base_url = ProviderClient::BASE_URL

    # 2. Stubbing: Tell WebMock what to expect.
    # "If anyone tries to POST to provider.example.com... return this JSON."
    stub_request(:post, "#{base_url}/transactions/init")
      .with(
        body: hash_including({ "amount" => 1000, "currency" => "EUR" })
      )
      .to_return(
        status: 200,
        body: { transaction_id: "123_abc", status: "pending" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    # 3. Act: Make the request to OUR controller
    post "/gateway/transactions", params: payload, as: :json

    # 4. Assert: Check the results
    assert_response :success

    # Parse the response from our controller
    json_response = JSON.parse(response.body)

    # Verify we return the correct redirect_url structure
    expected_url = "http://www.example.com/transactions/auth/123_abc"
    assert_equal expected_url, json_response["redirect_url"]
  end

  test "should return error when provider fails (non-200)" do
    payload = { amount: 1000, currency: "EUR", id: "unique_id" }
    base_url = ProviderClient::BASE_URL

    # Stubbing: Провайдер возвращает 500 Internal Server Error
    stub_request(:post, "#{base_url}/transactions/init")
      .to_return(
        status: 500,
        body: { error: "Something went wrong" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    post "/gateway/transactions", params: payload, as: :json

    # Assert: Мы ожидаем статус 502 (Bad Gateway)
    assert_response :bad_gateway

    json_response = JSON.parse(response.body)
    # Проверяем, что текст ошибки пробросился
    assert_match /Provider failed/, json_response["error"]
  end
end
