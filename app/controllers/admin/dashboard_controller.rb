module Admin
  class DashboardController < BaseController
    def show
      @orders = Order.includes(:user).order(created_at: :desc)
      @today_orders = @orders.where(created_at: Time.current.beginning_of_day..Time.current.end_of_day)
      @paid_orders = @orders.where(payment_status: "paid")
      @today_revenue_by_currency = @today_orders.where(payment_status: "paid").group(:currency).sum(:total_cents)
      @revenue_by_currency = @paid_orders.group(:currency).sum(:total_cents)
      @pending_orders = @orders.where(status: %w[received preparing ready out_for_delivery])
      @fulfillment_counts = @orders.group(:fulfillment_type).count
      @status_counts = @orders.group(:status).count
      @payment_counts = @orders.group(:payment_status).count
      @available_products = Product.where(published: true, available: true).count
      @pizzeria_setting = PizzeriaSetting.instance
    end
  end
end
