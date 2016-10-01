class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :url
      t.integer :view_count, default: 0

      t.timestamps
    end
    add_index :videos, [:created_at]
  end
end
