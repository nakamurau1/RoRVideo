class RemovePrivateFlgFromLists < ActiveRecord::Migration
  def change
    remove_column :lists, :private_flg, :boolean
  end
end
