class AddDeliveryZoneAndFeeToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :delivery_zone, :string
    add_column :orders, :delivery_fee_cents, :integer, null: false, default: 0
  end
end
