class AddProductSalesChannel < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :sales_channel, :string, null: false, default: "online"
  end
end
