class AddUniqUserNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :uniq_user_name, :string
  end
end
