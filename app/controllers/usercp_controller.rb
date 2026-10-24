class UsercpController < ApplicationController
  before_action :require_user!

  def show
    @orders = current_user.orders.includes(order_items: :product).order(created_at: :desc)
    @spent_by_currency = @orders.where(payment_status: "paid").group(:currency).sum(:total_cents)
    @pending_orders = @orders.where.not(status: %w[completed cancelled]).count
    @featured_products = Product.where(published: true, available: true).order(created_at: :desc).limit(3)
  end
end
