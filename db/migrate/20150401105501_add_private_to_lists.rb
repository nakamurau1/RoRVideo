class AddPrivateToLists < ActiveRecord::Migration
  def change
    add_column :lists, :private, :boolean, default: false
  end
end
