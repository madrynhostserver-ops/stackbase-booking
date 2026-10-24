class StripeWebhooksController < ActionController::API
  def create
    event = Stripe::Webhook.construct_event(
      request.body.read,
      request.headers["Stripe-Signature"],
      ENV.fetch("STRIPE_WEBHOOK_SECRET"),
    )

    handle_checkout_completed(event) if event.type == "checkout.session.completed"
    head :ok
  rescue JSON::ParserError, Stripe::SignatureVerificationError, KeyError, ActiveRecord::RecordNotFound,
         Order::PaymentVerificationError => e
    Rails.logger.warn("Invalid Stripe webhook: #{e.class}: #{e.message}")
    head :bad_request
  end

  private

  def handle_checkout_completed(event)
    session = event.data.object
    order_id = session.metadata&.order_id
    raise Order::PaymentVerificationError, "Missing order metadata" if order_id.blank?
    raise Order::PaymentVerificationError, "Checkout payment is not paid" unless session.payment_status == "paid"

    order = Order.find_by!(id: order_id, stripe_checkout_session_id: session.id)
    order.mark_paid!(
      payment_intent_id: session.payment_intent,
      stripe_event_id: event.id,
      amount_cents: session.amount_total,
      currency: session.currency,
    )
  end
end
