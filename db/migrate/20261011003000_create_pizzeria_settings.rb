class CreatePizzeriaSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :pizzeria_settings do |t|
      t.string :address, null: false
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7
      t.timestamps
    end
  end
end
