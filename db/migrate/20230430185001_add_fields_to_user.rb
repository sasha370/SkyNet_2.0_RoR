class AddFieldsToUser < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :login, :first_name

    add_column :users, :last_name, :string
    add_column :users, :is_bot, :boolean, default: false
    add_column :users, :username, :string
    add_column :users, :telegram_id, :string
    add_column :users, :language_code, :string
    add_column :users, :is_premium, :boolean, default: false
  end
end
