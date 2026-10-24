require "test_helper"

class ProductTest < ActiveSupport::TestCase
  test "requires a positive price" do
    product = Product.new(name: "Demo", description: "Description", download_url: "https://example.com", price_cents: 0)

    assert_not product.valid?
    assert_includes product.errors[:price_cents], "must be greater than 0"
  end
end
