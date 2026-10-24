require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "order@example.com", password: "Password123!")
    @product = Product.create!(
      name: "Test pizza",
      description: "Tomate y mozzarella",
      price_cents: 1290,
      currency: "eur",
      download_url: "",
      category: "pizza",
      available: true,
      published: true,
    )
  end

  test "customer can create a delivery order with quantity" do
    post session_url, params: { email: @user.email, password: "Password123!" }

    assert_difference("Order.count", 1) do
      post orders_url, params: {
        product_id: @product.id,
        quantity: 2,
        fulfillment_type: "delivery",
        delivery_zone: "zone_1",
        delivery_address: "Calle Mayor 10",
        phone: "+34 600 000 000",
        notes: "Llamar al llegar",
      }
    end

    order = Order.order(:id).last
    assert_redirected_to product_url(@product)
    assert_equal 2580, order.total_cents
    assert_equal 0, order.delivery_fee_cents
    assert_equal "delivery", order.fulfillment_type
    assert_equal 2, order.order_items.first.quantity
  end

  test "delivery order requires an address" do
    post session_url, params: { email: @user.email, password: "Password123!" }

    assert_no_difference("Order.count") do
      post orders_url, params: {
        product_id: @product.id,
        fulfillment_type: "delivery",
        delivery_zone: "zone_1",
        phone: "+34 600 000 000",
      }
    end

    assert_redirected_to product_url(@product)
    follow_redirect!
    assert_includes response.body, "Revisa los datos de entrega"
  end
end
