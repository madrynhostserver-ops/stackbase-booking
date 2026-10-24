class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  validates :unit_price_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :quantity, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 20 }
end
