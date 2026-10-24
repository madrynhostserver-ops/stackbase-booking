require "test_helper"

class AdminAccessTest < ActionDispatch::IntegrationTest
  test "anonymous visitors cannot access admin products" do
    get admin_products_url

    assert_redirected_to new_session_url
  end

  test "admin can access the business control panel" do
    admin = User.create!(email: "metrics-admin@example.com", password: "Password123!", role: "admin")
    post session_url, params: { email: admin.email, password: "Password123!" }

    get admincp_url

    assert_response :success
    assert_includes response.body, "Operations dashboard"
  end

  test "customer can access their customer panel" do
    user = User.create!(email: "panel-customer@example.com", password: "Password123!")
    post session_url, params: { email: user.email, password: "Password123!" }

    get usercp_url

    assert_response :success
    assert_includes response.body, "My orders"
  end

  test "customers cannot access admin products" do
    user = User.create!(email: "customer@example.com", password: "Password123!")
    post session_url, params: { email: user.email, password: "Password123!" }
    get admin_products_url

    assert_redirected_to root_url
  end

  test "admin rejects an invalid order status" do
    admin = User.create!(email: "admin@example.com", password: "Password123!", role: "admin")
    customer = User.create!(email: "customer-order@example.com", password: "Password123!")
    order = customer.orders.create!(
      total_cents: 1290,
      currency: "eur",
      fulfillment_type: "pickup",
      phone: "+34 600 000 000",
    )
    post session_url, params: { email: admin.email, password: "Password123!" }

    patch admin_order_url(order), params: { status: "refunded" }

    assert_redirected_to admin_orders_url
    assert_equal "received", order.reload.status
  end
end
