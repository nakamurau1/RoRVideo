class VideoComment < ActiveRecord::Base
	belongs_to :video
	belongs_to :user
	default_scope -> { order('created_at DESC') }

	def user_name
		user = User.find_by(id: user_id)
		user.name
	end
end
