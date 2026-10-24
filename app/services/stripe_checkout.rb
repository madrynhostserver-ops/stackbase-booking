class StripeCheckout
  def initialize(order:, success_url:, cancel_url:)
    @order = order
    @success_url = success_url
    @cancel_url = cancel_url
  end

  def call
    raise "STRIPE_SECRET_KEY is not configured" if ENV["STRIPE_SECRET_KEY"].blank?

    Stripe::Checkout::Session.create(
      mode: "payment",
      customer_email: @order.user.email,
      line_items: @order.order_items.map { |item| line_item(item) },
      metadata: { order_id: @order.id.to_s },
      success_url: @success_url,
      cancel_url: @cancel_url,
    )
  end

  private

  def line_item(item)
    {
      quantity: item.quantity,
      price_data: {
        currency: item.product.currency,
        unit_amount: item.unit_price_cents,
        product_data: {
          name: item.product.name,
          description: item.product.description.truncate(500),
        },
      },
    }
  end
end
