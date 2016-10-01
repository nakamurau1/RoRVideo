class List < ActiveRecord::Base
	belongs_to :user
	has_many :list_items
	has_many :videos, through: :list_items
	has_many :followed_lists, dependent: :destroy
	has_many :followers, through: :followed_lists, source: :user
	validates :name, presence: true, length: {maximum: 50}
	validates :comment, length: {maximum: 500}

	# Listに動画を追加します。追加済みの場合は除外します。
	def toggle(video)

		alredy = self.list_items.where(video_id: video.id).first

		if alredy
			# 既に追加済みの場合
			alredy.destroy			
		else
			# Listに追加
			self.list_items.create!(video_id: video.id)
		end
	end

	# Listに追加済みか否かを判定します。
	def favorite?(video)

		self.list_items.where(video_id: video.id).size > 0
	end

end
