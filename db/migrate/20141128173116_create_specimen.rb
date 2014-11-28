class CreateSpecimen < ActiveRecord::Migration
  def change
    create_table :specimen do |t|
      t.belongs_to :species, null: false
      t.belongs_to :location, null: false

      t.references :legator, null: false
      t.string :legator_text

      t.references :determinator
      t.string :determinator_text

      t.text :habitats
      t.text :substrates

      t.date :date, null: false
      t.text :quantity

      t.text :note

      t.boolean :approved

      t.string :uuid

      t.timestamps
    end

    add_index :specimen, :uuid, unique: true
    add_index :specimen, :species_id
    add_index :specimen, :location_id
    add_index :specimen, :legator_id
    add_index :specimen, :determinator_id
  end
end
