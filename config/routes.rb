Rails.application.routes.draw do
  post "/gateway/transactions", to: "gateway#create"
  get "up" => "rails/health#show", as: :rails_health_check
end
