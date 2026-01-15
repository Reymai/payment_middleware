Rails.application.routes.draw do
  post "/gateway/transactions", to: "gateway#create"
  get "/transactions/auth/:id", to: "transactions#auth", as: :transactions_auth
  get "up" => "rails/health#show", as: :rails_health_check
end
