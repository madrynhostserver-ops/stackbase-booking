class AddPizzaOrderDetails < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :fulfillment_type, :string, null: false, default: "pickup"
    add_column :orders, :delivery_address, :string
    add_column :orders, :phone, :string
    add_column :orders, :notes, :text
    add_column :products, :category, :string, null: false, default: "pizza"
    add_column :products, :available, :boolean, null: false, default: true
  end
end
