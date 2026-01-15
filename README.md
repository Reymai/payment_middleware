# Payment Gateway Middleware

This is a Ruby on Rails application acting as a **middleware** between a Gateway system and a Provider system. It handles transaction initialization and user authorization flows, adhering to strict architectural and testing requirements.

## 🚀 Features

* **Init Flow:** Accepts requests from the Gateway, forwards them to the Provider, and generates a custom redirect URL.
* **Auth Flow:** Handles user redirection, confirms payment authorization with the Provider, and displays the final status.
* **Service Object Architecture:** Encapsulates external API logic in `ProviderClient`, keeping controllers clean.
* **Test Coverage:** Fully tested using `Minitest` and `WebMock` (zero real external HTTP calls).
* **Configurable:** Uses Environment Variables for external URLs.

## 🛠 Prerequisites

* Ruby 3.x
* Rails 7.x / 8.x
* Bundler

## ⚙️ Setup & Installation

1.  **Clone the repository:**
    ```bash
    git clone <repository_url>
    cd payment_middleware
    ```

2.  **Install dependencies:**
    ```bash
    bundle install
    ```

3.  **Configure Environment Variables (Important):**
    This application uses `dotenv` to manage configuration. You must create a `.env` file in the root directory.

    ```bash
    # Create the file
    touch .env
    ```

    Open `.env` and add the Provider URL:
    ```env
    PROVIDER_URL=https://provider.example.com
    ```

## 🧪 Running Tests

The test suite uses `minitest` and `webmock` to stub all external HTTP requests. No real network calls are made during testing.

Run the full suite:
```bash
bin/rails test
```

Expected output: `0 failures, 0 errors`.

## 🔌 API Documentation

### 1. Initialize Transaction (Gateway -> Middleware)

* **Endpoint:** `POST /gateway/transactions`
* **Description:** Called by the Gateway to start the payment process.
* **Request Body:**
    ```json
    {
      "amount": 1000,
      "currency": "EUR",
      "id": "unique_id"
    }
    ```
* **Response (200 OK):**
    ```json
    {
      "redirect_url": "http://localhost:3000/transactions/auth/123_abc"
    }
    ```

### 2. Authorize Transaction (User -> Middleware)

* **Endpoint:** `GET /transactions/auth/:id`
* **Description:** The user is redirected to this URL by the Gateway. The system internally calls the Provider to authorize the transaction.
* **Response:**
    * Returns plain text **"success"** if the Provider returns `{ "status": "success" }`.
    * Returns plain text **"failed"** otherwise.

## 🛡 Security Audit & Improvements

As per the assignment requirements ("Identify security issues"), the following potential vulnerabilities and improvements have been identified for a production environment:

### 1. Lack of Authentication
* **Issue:** The `POST /gateway/transactions` endpoint is currently public. Any malicious actor could spam this endpoint, creating fake transactions and overloading the Provider's API.
* **Fix:** Implement API Key authentication (e.g., checking for an `Authorization: Bearer <TOKEN>` header) to verify that requests originate from the trusted Gateway.

### 2. Input Validation
* **Issue:** The application passes `amount` and `currency` directly to the Provider without validation.
* **Fix:** Add `ActiveModel::Validations` or `dry-validation` logic to ensure `amount` is a positive number and `currency` adheres to ISO 4217 standards before making external calls.

### 3. Transaction ID Enumeration
* **Issue:** If the Provider returns sequential IDs (e.g., 1001, 1002), an attacker could guess the `redirect_url` of other users (e.g., `/transactions/auth/1002`) and potentially trigger authorization for a transaction that isn't theirs.
* **Fix:** Use unpredictable UUIDs for transaction identifiers or sign the redirect URL with an HMAC token to prevent tampering.

### 4. CSRF Protection
* **Note:** CSRF protection was intentionally disabled (`skip_before_action`) for the `GatewayController` to allow server-to-server communication.
* **Improvement:** Ensure this endpoint remains strictly stateless and does not rely on session cookies.

## 📦 Project Tech Stack

* **Ruby on Rails** - API Framework
* **Faraday** - HTTP Client
* **WebMock** - HTTP Stubbing for tests
* **Dotenv** - Environment Configuration