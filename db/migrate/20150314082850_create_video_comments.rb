class CreateVideoComments < ActiveRecord::Migration
  def change
    create_table :video_comments do |t|
      t.integer :video_id
      t.integer :user_id
      t.string :comment

      t.timestamps
    end
    add_index :video_comments, [:video_id, :created_at]
  end
end
