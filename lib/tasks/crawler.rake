require 'open-uri'
require 'kconv'
require 'pry'

namespace :db do
	desc "Crawl videos"

	task crawl: :environment do

		puts "収集開始=========================================="

		# ぬきストからは収集しない。
		# → javynowの再生速度が遅いため
		# crawl_nukistream

		crawl_youtube

		puts "収集完了=========================================="

	end
end

# データ収集用のビデオオブジェクト
class TempVideo
	attr_accessor :page_url, :video_url, :thumbnail_url, :title, :play_time

	def print
		puts "---------------------------------------"
		puts "page_url : #{page_url}"
		puts "video_url : #{video_url}"
		puts "video_type : #{get_video_type}"
		puts "thumbnail_url : #{thumbnail_url}"
		puts "title : #{title}"
		puts "---------------------------------------"
	end

	def get_v_id

		case self.get_video_type
		when "youtube"
			return get_youtube_video_id
		when "javynow"
			return get_javynow_video_id
		when "xvideos"
			return get_xvideos_video_id
		when "redtube"
			return get_redtube_video_id
		when "pornhost"
			return get_pornhost_video_id
		end
	end

	def get_video_type

		return "" if self.video_url.blank?

		if self.video_url.index("youtube")
			# youtube

			return "youtube"

		elsif self.video_url.index("javynow")
			# javynow

			return "javynow"

		elsif self.video_url.index("xvideos")

			return "xvideos"

		elsif self.video_url.index("redtube")

			return "redtube"

		elsif self.video_url.index("pornhost")

			return "pornhost"
		end

		return ""
	end

	private
		# urlからyoutubeのvideoIdを取得
		def get_youtube_video_id
			query_string = URI.parse(self.video_url).query
			parameters = Hash[URI.decode_www_form(query_string)]
			parameters['v']
		end

		# urlからxvideoのvideoIdを取得
		def get_xvideos_video_id
			re = Regexp.new('/embedframe/(.*)')
			m = re.match(self.video_url)
			return m[1]
		end

		# urlからjavynowのvideoIdを取得
		def get_javynow_video_id
			query_string = URI.parse(self.video_url).query
			parameters = Hash[URI.decode_www_form(query_string)]
			parameters['id']
		end

		# urlからredtubeのvideoIdを取得
		def get_redtube_video_id
			query_string = URI.parse(self.video_url).query
			parameters = Hash[URI.decode_www_form(query_string)]
			parameters['id']
		end

		# urlからpornhostのvideoIDを取得
		def get_pornhost_video_id
			re = Regexp.new('/embed/(.*)')
			m = re.match(self.video_url)
			return m[1]
		end
end

class TempVideoList
	include Enumerable

	def initialize
		@videos = []
	end

	def each(&block)
		@videos.each(&block)
	end

	def add_video(new_video)
		@videos << new_video
	end

	def get_video_by_page_url(page_url)
		@videos.select{|v| v.page_url == page_url}.first
	end

	# DBにデータを出力します
	def write_to_db
		@videos.each do |v|

			# 既に追加済みの場合は次のLoopへ
			next if Video.exists?(v_id: v.get_v_id, video_type: v.get_video_type)
			# video_urlが設定されていない場合は保存しない
			next if v.video_url.blank?
			# 未対応の動画サイトの場合は保存しない
			next if v.get_video_type.blank?

			Video.create!(v_id: v.get_v_id(),
				  video_type: v.get_video_type(),
                  thumbnail_url: v.thumbnail_url,
                  title: v.title,
                  play_time: v.play_time)
		end
	end

end

def crawl_youtube

	# Videoオブジェクトを格納する
	video_list = TempVideoList.new()

	root_url = "https://www.youtube.com/"

	start_url = "https://www.youtube.com/results?q=ruby+on+rails&sp=CAI%253D"

	video_page_urls = []

	doc = Nokogiri::HTML(open(start_url))

	ol_node = doc.xpath("//ol[@class='item-section']")
	li_nodes = ol_node.xpath("li")

	li_nodes.each do |node|

		# 広告か否か
		is_ad = node.xpath(".//span[@class='yt-badge ad-badge-byline yt-badge-ad']").to_s
		# 広告は飛ばす
		next if !is_ad.empty?

		title_node = node.xpath(".//h3[@class='yt-lockup-title ']")
		title = title_node.xpath("a").text

		thumbnail_node = node.xpath(".//span[@class='yt-thumb-simple']")
		img_tag = thumbnail_node.xpath(".//img")

		thumbnail_url = img_tag.attribute('src')
		if !thumbnail_url.to_s.index(".jpg")
			thumbnail_url = img_tag.attribute('data-thumb')
		end

		# URLの余計な部分を取り除く
		md = thumbnail_url.to_s.match(/(https.+\.jpg)/)

		if md
			thumbnail_url = md[0]
		end

		# 動画のURL
		page_url = title_node.xpath(".//a")[0].attribute('href')
		full_path = root_url + page_url.text

		video_page_urls.push(full_path)

		# オブジェクトを作成
		new_video = TempVideo.new()
		new_video.title = title
		new_video.page_url = full_path
		new_video.thumbnail_url = thumbnail_url
		new_video.video_url = full_path

		new_video.print

		video_list.add_video(new_video)
	end

	# Anemone.crawl(video_page_urls, :depth_limit => 0) do |anemone|
	#
	# 	anemone.on_every_page do |page|
	#
	# 		doc = Nokogiri::HTML.parse(page.body.toutf8)
	#
	# 		mainVideo = doc.xpath("//*[@id='mainVideo']")
	# 		player = mainVideo.xpath(".//*[@class='player']")
	#
	# 		title = mainVideo.xpath(".//h1")[0].content
	# 		video_url = player.xpath(".//iframe")[0].attribute('src')
	#
	# 		# コレクションからオブジェクトを抽出
	# 		got_video = video_list.get_video_by_page_url(page.url.to_s)
	# 		# プロパティを設定
	# 		got_video.title = title
	# 		got_video.video_url = video_url.text
	# 	end
	# end

	video_list.write_to_db
end

# # 再生時間のテキストを解析し分に直して返します。
# # 引数：再生時間を表す文字列（例：00:02:55）
# def parse_play_time_text(play_time_text)
# 	# 正規表現
# 	re = "(\\d\\d):(\\d\\d):(\\d\\d)"
#
# 	md = /#{re}/.match(play_time_text)
#
# 	return 0 if md.nil?
#
# 	hour = md[1].to_i
# 	minutes = md[2].to_i
# 	seconds = md[3].to_i
#
# 	total_minutes = (hour * 60) + minutes
# end
