require "test_helper"
require "ostruct"

class StripeWebhooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    ENV["STRIPE_WEBHOOK_SECRET"] = "whsec_test"
    @user = User.create!(email: "stripe@example.com", password: "Password123!")
    @product = Product.create!(
      name: "Stripe pizza",
      description: "Test",
      price_cents: 1290,
      currency: "eur",
      download_url: "",
      category: "pizza",
      available: true,
      published: true,
    )
    @order = @user.orders.create!(
      total_cents: 1290,
      currency: "eur",
      phone: "+34 600 000 000",
      stripe_checkout_session_id: "cs_test",
    )
    @order.order_items.create!(product: @product, unit_price_cents: 1290, quantity: 1)
  end

  test "rejects unsigned webhooks" do
    post stripe_webhook_url, params: "{}"

    assert_response :bad_request
  end

  test "confirms a paid checkout with matching amount and currency" do
    event = checkout_event(amount_total: 1290, currency: "eur")

    with_constructed_event(event) do
      post stripe_webhook_url, params: "{}"
    end

    assert_response :ok
    assert @order.reload.paid?
    assert_equal "received", @order.status
    assert_equal "evt_test", @order.stripe_event_id
  end

  test "repeated webhook is idempotent" do
    event = checkout_event(amount_total: 1290, currency: "eur")

    with_constructed_event(event) do
      2.times { post stripe_webhook_url, params: "{}" }
    end

    assert_response :ok
    assert_equal 1, @order.reload.order_items.count
    assert_equal "evt_test", @order.stripe_event_id
  end

  test "rejects a webhook with a mismatched amount" do
    event = checkout_event(amount_total: 1291, currency: "eur")

    with_constructed_event(event) do
      post stripe_webhook_url, params: "{}"
    end

    assert_response :bad_request
    assert_equal "pending", @order.reload.payment_status
  end

  test "rejects a checkout that Stripe has not marked paid" do
    event = checkout_event(amount_total: 1290, currency: "eur", payment_status: "unpaid")

    with_constructed_event(event) do
      post stripe_webhook_url, params: "{}"
    end

    assert_response :bad_request
    assert_equal "pending", @order.reload.payment_status
  end

  private

  def checkout_event(amount_total:, currency:, payment_status: "paid")
    metadata = OpenStruct.new(order_id: @order.id.to_s)
    session = OpenStruct.new(
      id: "cs_test",
      metadata: metadata,
      payment_status: payment_status,
      amount_total: amount_total,
      currency: currency,
      payment_intent: "pi_test",
    )
    OpenStruct.new(id: "evt_test", type: "checkout.session.completed", data: OpenStruct.new(object: session))
  end

  def with_constructed_event(event)
    original = Stripe::Webhook.method(:construct_event)
    Stripe::Webhook.define_singleton_method(:construct_event) { |*_args| event }
    yield
  ensure
    Stripe::Webhook.define_singleton_method(:construct_event, original)
  end
end
