require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "catalog is publicly available" do
    Product.create!(
      name: "Public product",
      description: "Description",
      price_cents: 4900,
      currency: "eur",
      download_url: "https://example.com/download",
    )

    get root_url

    assert_response :success
    assert_includes response.body, "Public product"
  end
end
