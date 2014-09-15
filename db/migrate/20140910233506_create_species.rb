class CreateSpecies < ActiveRecord::Migration
  def change
    create_table :species do |t|
      t.string :name, null: false
      t.string :genus, null: false
      t.string :familia, null: false
      t.string :ordo, null: false
      t.string :subclassis, null: false
      t.string :classis, null: false
      t.string :subphylum, null: false
      t.string :phylum, null: false

      t.text :synonyms

      t.string :growth_type
      t.string :nutritive_group

      t.string :url, unique: true
      t.string :uuid

      t.timestamps
    end

    add_index :species, :uuid, unique: true
    add_index :species, :url, unique: true
    add_index :species, [:name, :genus]
  end
end
