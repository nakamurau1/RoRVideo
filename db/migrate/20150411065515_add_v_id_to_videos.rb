class AddVIdToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :v_id, :string
  end
end
