class CreateReferences < ActiveRecord::Migration
  def change
    create_table :references do |t|
      t.string :title, null: false
      t.string :authors
      t.string :isbn, unique: true
      t.string :url, unique: true
      t.string :uuid, unique: true

      t.timestamps
    end

    add_index :references, :uuid, unique: true
  end
end
