class DeviseCreateUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      ## Database authenticatable
      t.string :email, null: false
      t.string :encrypted_password

      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :title
      t.string :role, null: false, default: User::USER_ROLE
      t.string :institution
      t.string :phone

      t.string :uuid

      t.string :authentication_token

      t.datetime :deactivated_at

      ## Recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      ## Trackable
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip

      ## Confirmable
      t.string :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string :unconfirmed_email # Only if using reconfirmable

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :uuid, unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :authentication_token, unique: true
    add_index :users, :confirmation_token,   unique: true
  end
end
