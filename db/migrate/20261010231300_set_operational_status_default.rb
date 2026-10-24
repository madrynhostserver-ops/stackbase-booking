class SetOperationalStatusDefault < ActiveRecord::Migration[8.1]
  def change
    change_column_default :orders, :status, from: "pending", to: "received"
  end
end
