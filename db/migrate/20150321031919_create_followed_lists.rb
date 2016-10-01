class CreateFollowedLists < ActiveRecord::Migration
  def change
    create_table :followed_lists do |t|
      t.integer :user_id
      t.integer :list_id

      t.timestamps
    end
  end
end
