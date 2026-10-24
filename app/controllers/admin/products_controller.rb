module Admin
  class ProductsController < BaseController
    before_action :set_product, only: %i[edit update destroy toggle_active]

    def index
      @products = Product.order(created_at: :desc)
      @orders = Order.all
    end

    def new
      @product = Product.new(category: Product::CATEGORIES.include?(params[:category]) ? params[:category] : "pizza", currency: "eur", sales_channel: "online")
    end

    def create
      @product = Product.new(product_params)
      if @product.save
        redirect_to admin_products_path, notice: "Pizza creada."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @product.update(product_params)
        redirect_to admin_products_path, notice: "Pizza actualizada."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @product.update!(published: false, available: false)
      redirect_to admin_products_path, notice: "Pizza retirada del menú."
    end

    def toggle_active
      active = !(@product.published? && @product.available?)
      @product.update!(published: active, available: active)
      redirect_to admin_products_path, notice: active ? "Pizza activada." : "Pizza desactivada."
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
      params.require(:product).permit(:name, :description, :price_cents, :currency, :category, :sales_channel, :image, :published, :available)
    end
  end
end
