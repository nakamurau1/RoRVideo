class CreateListItems < ActiveRecord::Migration
  def change
    create_table :list_items do |t|
      t.integer :list_id
      t.integer :video_id

      t.timestamps
    end
    add_index :list_items, [:list_id]
  end
end
