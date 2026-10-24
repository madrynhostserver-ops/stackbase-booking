class BikercpController < ApplicationController
  before_action :require_worker_or_admin!
  before_action :require_biker!, only: :update_location

  def show
    @pizzeria_setting = PizzeriaSetting.instance
    @bikers = User.where(role: "biker").includes(:assigned_orders).order(:email)
    orders = admin? ? Order.where.not(biker_id: nil) : current_user.assigned_orders
    @orders = orders.includes(:user, order_items: :product)
      .where(status: %w[received preparing ready out_for_delivery])
      .order(created_at: :asc)
  end

  def update_location
    order = current_user.assigned_orders.find(params[:id])
    order.update!(
      biker_latitude: location_params[:latitude],
      biker_longitude: location_params[:longitude],
      biker_location_updated_at: Time.current,
    )
    render json: { ok: true, updated_at: order.biker_location_updated_at.iso8601 }
  end

  private

  def require_worker_or_admin!
    return if biker? || admin?

    redirect_to root_path, alert: I18n.t("flash.biker_required")
  end

  def require_biker!
    return if current_user&.role == "biker"

    render json: { error: "Only bikers can update location." }, status: :forbidden
  end

  def location_params
    params.permit(:latitude, :longitude)
  end
end
