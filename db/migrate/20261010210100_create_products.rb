class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.integer :price_cents, null: false
      t.string :currency, null: false, default: "eur"
      t.string :download_url, null: false
      t.string :stripe_price_id
      t.boolean :published, null: false, default: true
      t.timestamps
    end
  end
end
