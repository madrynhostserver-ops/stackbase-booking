module Admin
  class OrdersController < BaseController
    def index
      @orders = Order.includes(:user).order(created_at: :desc)
      @bikers = User.where(role: "biker").order(:email)
    end

    def show
      @order = Order.includes(:user, order_items: :product).find(params[:id])
      @bikers = User.where(role: "biker").order(:email)
    end

    def update
      order = Order.find(params[:id])
      status = params.require(:status)
      unless Order::STATUSES.include?(status) && status != "paid"
        redirect_to admin_orders_path, alert: "Estado de pedido no válido."
        return
      end

      biker = User.where(role: "biker").find_by(id: params[:biker_id].presence)
      if biker && !assignable_to_biker?(order, status)
        redirect_to admin_orders_path, alert: "Only active delivery orders can be assigned to a biker."
        return
      end

      order.update!(status: status, biker: %w[completed cancelled].include?(status) ? nil : biker)
      redirect_to admin_orders_path, notice: "Estado del pedido actualizado."
    end

    def assign_biker
      order = Order.find(params[:id])
      biker = User.where(role: "biker").find_by(id: params[:biker_id])
      if biker && !assignable_to_biker?(order, order.status)
        redirect_to admin_orders_path, alert: "Only active delivery orders can be assigned to a biker."
        return
      end

      order.update!(biker: biker)
      redirect_to admin_orders_path, notice: biker ? "Pedido asignado al biker." : "Biker retirado del pedido."
    end

    private

    def assignable_to_biker?(order, status)
      order.fulfillment_type == "delivery" && %w[received preparing ready out_for_delivery].include?(status)
    end
  end
end
