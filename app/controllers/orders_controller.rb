class OrdersController < ApplicationController
  before_action :require_user!

  def show
    @order = current_user.orders.includes(order_items: :product).find(params[:id])
  end

  def tracking
    order = current_user.orders.find(params[:id])
    render json: {
      status: order.status,
      latitude: order.biker_latitude,
      longitude: order.biker_longitude,
      delivery_latitude: order.delivery_latitude,
      delivery_longitude: order.delivery_longitude,
      updated_at: order.biker_location_updated_at&.iso8601,
    }
  end

  def create
    product = Product.published.find(params[:product_id])
    raise Product::StoreOnlyError unless product.online_orderable?
    raise PizzeriaRules::ClosedError, "La pizzería está cerrada en este momento." unless PizzeriaRules.open?

    fulfillment_type = order_params[:fulfillment_type].presence || "pickup"
    quantity = order_params[:quantity].to_i.clamp(1, 20)
    subtotal_cents = product.price_cents * quantity
    delivery_zone = fulfillment_type == "delivery" ? order_params[:delivery_zone] : nil
    delivery_fee_cents = fulfillment_type == "delivery" ? PizzeriaRules.delivery_quote(
      zone: delivery_zone,
      subtotal_cents: subtotal_cents,
    ) : 0
    order = current_user.orders.create!(
      total_cents: subtotal_cents + delivery_fee_cents,
      currency: product.currency,
      fulfillment_type: fulfillment_type,
      delivery_zone: delivery_zone,
      delivery_fee_cents: delivery_fee_cents,
      delivery_address: order_params[:delivery_address],
      delivery_latitude: order_params[:delivery_latitude],
      delivery_longitude: order_params[:delivery_longitude],
      phone: order_params[:phone],
      notes: order_params[:notes],
    )
    order.order_items.create!(product: product, unit_price_cents: product.price_cents, quantity: quantity)

    checkout = StripeCheckout.new(
      order: order,
      success_url: success_order_url(order),
      cancel_url: product_url(product),
    ).call
    order.update!(stripe_checkout_session_id: checkout.id)

    redirect_to checkout.url, allow_other_host: true, status: :see_other
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.info("Invalid order rejected: #{e.record.errors.full_messages.to_sentence}")
    redirect_to product_path(product), alert: "Revisa los datos de entrega y teléfono."
  rescue PizzeriaRules::InvalidDelivery, PizzeriaRules::ClosedError => e
    Rails.logger.info("Order rejected by pizzeria rules: #{e.message}")
    redirect_to product_path(product), alert: e.message
  rescue Product::StoreOnlyError
    redirect_to product_path(product), alert: I18n.t("flash.store_only_product")
  rescue Stripe::StripeError, RuntimeError => e
    Rails.logger.error("Stripe checkout failed: #{e.class}: #{e.message}")
    redirect_to product_path(product), alert: I18n.t("flash.checkout_unavailable")
  end

  private

  def order_params
    params.permit(:quantity, :fulfillment_type, :delivery_zone, :delivery_address, :delivery_latitude, :delivery_longitude, :phone, :notes)
  end

  def success
    @order = current_user.orders.includes(order_items: :product).find(params[:id])
    redirect_to order_path(@order), notice: "Pago recibido. Estamos confirmando tu pedido." unless @order.paid?
  end
end
