class AddBikerTrackingToOrders < ActiveRecord::Migration[8.1]
  def change
    add_reference :orders, :biker, foreign_key: { to_table: :users }, index: true
    add_column :orders, :biker_latitude, :decimal, precision: 10, scale: 7
    add_column :orders, :biker_longitude, :decimal, precision: 10, scale: 7
    add_column :orders, :biker_location_updated_at, :datetime
  end
end
