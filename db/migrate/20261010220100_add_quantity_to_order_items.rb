class AddQuantityToOrderItems < ActiveRecord::Migration[8.1]
  def change
    add_column :order_items, :quantity, :integer, null: false, default: 1
  end
end
