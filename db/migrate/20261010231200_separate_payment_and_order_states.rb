class SeparatePaymentAndOrderStates < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :payment_status, :string, null: false, default: "pending"
    add_column :orders, :stripe_event_id, :string
    add_index :orders, :stripe_event_id, unique: true

    reversible do |direction|
      direction.up do
        execute <<~SQL
          UPDATE orders
          SET payment_status = 'paid', status = 'received', paid_at = COALESCE(paid_at, CURRENT_TIMESTAMP)
          WHERE status = 'paid'
        SQL

        execute <<~SQL
          UPDATE orders
          SET status = 'received'
          WHERE status = 'pending'
        SQL
      end
    end
  end
end
