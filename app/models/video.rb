class Video < ActiveRecord::Base	    
	require 'uri'
	has_many :video_comments, dependent: :destroy
    validates :v_id,
      presence: true, uniqueness: {case_sensitive: false}
    validates :video_type, presence: true
	# belongs_to :list_item

	# 新着動画を返します
	def Video.get_new_videos
		# とりあえずすべての動画を返す
		Video.all
	end

	# 動画の視聴数をカウントアップします
	def count_up
		self.view_count += 1
		self.save
	end

	# 動画の埋め込みHTML
	def get_embeded_html

		width = 382
		height = 300

		if self.video_type == "youtube"
			# youtube

			return "<iframe width='560' height='315' src='https://www.youtube.com/embed/#{self.v_id}' frameborder='0' allowfullscreen></iframe>".html_safe

		elsif self.video_type == "javynow"
			# javynow

			return "<iframe src='http://javynow.com/player.php?id=#{self.v_id}&n=1&s=1&h=385' frameborder=0 width=#{width} height=#{height} scrolling=no></iframe>".html_safe

		elsif self.video_type == "xvideos"
			# xvideos

			return "<iframe src='http://flashservice.xvideos.com/embedframe/#{self.v_id}' frameborder=0 allowfullscreen width=#{width} height=#{height} scrolling=no></iframe>".html_safe

		elsif self.video_type == "redtube"
			# redtube

			return "<iframe src='http://embed.redtube.com/?id=#{self.v_id}&bgcolor=000000' frameborder=0 width=#{width} height=#{height} scrolling=no></iframe>".html_safe

		elsif self.video_type == "pornhost"

			return "<iframe src='http://www.pornhost.com/embed/#{self.v_id}' frameborder=0 allowfullscreen width=#{width} height=#{height} ></iframe>".html_safe
		end
	end

	# private
	# 	# urlからyoutubeのvideoIdを取得
	# 	def get_youtube_video_id
	# 		query_string = URI.parse(self.url).query
	# 		parameters = Hash[URI.decode_www_form(query_string)]
	# 		parameters['v']
	# 	end

	# 	# urlからxvideoのvideoIdを取得
	# 	def get_xvideos_video_id
	# 		re = Regexp.new('/video(.*)/')
	# 		m = re.match(self.url)
	# 		return m[1]
	# 	end

	# 	# urlからjavynowのvideoIdを取得
	# 	def get_javynow_video_id
	# 		query_string = URI.parse(self.url).query
	# 		parameters = Hash[URI.decode_www_form(query_string)]
	# 		parameters['id']
	# 	end
end
