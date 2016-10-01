class AddPlayTimeToVideos < ActiveRecord::Migration
  def change
  	add_column :videos, :play_time, :integer
  	add_index :videos, :play_time
  end
end
