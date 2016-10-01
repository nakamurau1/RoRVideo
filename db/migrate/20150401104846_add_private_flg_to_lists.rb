class AddPrivateFlgToLists < ActiveRecord::Migration
  def change
    add_column :lists, :private_flg, :boolean, default: false
  end
end
