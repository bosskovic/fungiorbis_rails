class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :username
      t.string :first_name
      t.string :last_name
      t.string :title
      t.string :role
      t.string :institution
      t.string :phone
      t.string :password
      t.string :authentication_token

      t.timestamps
    end
  end
end
