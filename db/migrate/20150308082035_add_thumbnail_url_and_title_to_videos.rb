class AddThumbnailUrlAndTitleToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :thumbnail_url, :string
    add_column :videos, :title, :string
  end
end
