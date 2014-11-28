class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name, null: false, unique: true
      t.string :utm, null: false

      t.string :uuid

      t.timestamps
    end

    add_index :locations, :uuid, unique: true
  end
end
