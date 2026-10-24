class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "pending"
      t.string :stripe_checkout_session_id
      t.string :stripe_payment_intent_id
      t.integer :total_cents, null: false
      t.string :currency, null: false, default: "eur"
      t.datetime :paid_at
      t.timestamps
    end

    add_index :orders, :stripe_checkout_session_id, unique: true
  end
end
