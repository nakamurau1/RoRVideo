class RemoveUrlFromVideos < ActiveRecord::Migration
  def change
    remove_column :videos, :url, :string
  end
end
