class CreateCharacteristics < ActiveRecord::Migration
  def change
    create_table :characteristics do |t|
      t.belongs_to :reference, null: false
      t.belongs_to :species, null: false

      t.boolean :edible
      t.boolean :cultivated
      t.boolean :poisonous
      t.boolean :medicinal

      t.text :fruiting_body
      t.text :microscopy
      t.text :flesh
      t.text :chemistry
      t.text :note

      t.text :habitats
      t.text :substrates

      t.string :uuid

      t.timestamps
    end

    add_index :characteristics, :uuid, unique: true
    add_index :characteristics, :reference_id
    add_index :characteristics, :species_id
  end
end
