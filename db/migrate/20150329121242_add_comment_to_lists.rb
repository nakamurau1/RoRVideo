class AddCommentToLists < ActiveRecord::Migration
  def change
    add_column :lists, :comment, :string
  end
end
