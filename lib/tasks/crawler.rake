require 'open-uri'
require 'kconv'

namespace :db do
	desc "Crawl videos"

	task crawl: :environment do

		# ぬきストからは収集しない。
		# → javynowの再生速度が遅いため
		crawl_nukistream

		crawl_babyshark

		# 開発中
		# crawl_agesage

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

# babyshark
def crawl_babyshark

	video_list = TempVideoList.new

	root_url = "http://babyshark.info/"

	video_page_urls = []

	10.times do |num|

		start_url = "#{root_url}/videos?page=#{num+1}"

		doc = Nokogiri::HTML(open(start_url))

		nodes = doc.xpath("//*[@class='media']")

		nodes.each do |node|

			page_url = node.xpath(".//a")[0].attribute('href')
			thumbnail_url = node.xpath(".//img")[0].attribute('data-original')
			bottom_left_text = node.xpath(".//*[@class='thumbnail-content bottom-left']")

			play_time_text = bottom_left_text.xpath(".//span")[0].content if !bottom_left_text.blank?

			if page_url.text.index("videos") == nil then
				# 外部サイトへのリンクは飛ばす

				next
			end

			full_path = "#{root_url}#{page_url}"
			full_thumbnail_path = "#{root_url}#{thumbnail_url.text}"

			video_page_urls.push(full_path)

			# オブジェクトを作成
			new_video = TempVideo.new()
			new_video.page_url = full_path
			new_video.thumbnail_url = full_thumbnail_path
			new_video.play_time = parse_play_time_text(play_time_text)

			video_list.add_video(new_video)
		end
	end

	Anemone.crawl(video_page_urls, :depth_limit => 0) do |anemone|

		anemone.on_every_page do |page|

			doc = Nokogiri::HTML.parse(page.body.toutf8)

			mainVideo = doc.xpath("//main")
			video_container = mainVideo.xpath(".//*[@class='video-container']")

			title = mainVideo.xpath(".//h1")[0].content
			iframe_tag = video_container.xpath(".//iframe")[0]

			# iframe（＝Xvideos）のみ収集する
			next if iframe_tag.blank?

			video_url = iframe_tag.attribute('src')

			# コレクションからオブジェクトを抽出
			got_video = video_list.get_video_by_page_url(page.url.to_s)
			# プロパティを設定
			got_video.title = title
			got_video.video_url = video_url.text
		end
	end

	video_list.write_to_db
end

# ぬきストリーム
def crawl_nukistream

	# Videoオブジェクトを格納する
	video_list = TempVideoList.new()

	root_url = "http://www.nukistream.com/"

	video_page_urls = []

	# 5ページ分の起点URLを作る
	10.times do |num|

		start_url = "#{root_url}?p=#{num+1}"

		doc = Nokogiri::HTML(open(start_url))

		nodes = doc.xpath("//*[@class='cntBox']")

		nodes.each do |node|
			page_url = node.xpath(".//a")[0].attribute('href')
			thumbnail_url = node.xpath(".//img")[0].attribute('src')

			if page_url.text.index("video") != 0 then
				# 外部サイトへのリンクは飛ばす
				next
			end

			full_path = root_url + page_url.text

			video_page_urls.push(full_path)

			# オブジェクトを作成
			new_video = TempVideo.new()
			new_video.page_url = full_path
			new_video.thumbnail_url = thumbnail_url.text

			video_list.add_video(new_video)
		end
	end

	Anemone.crawl(video_page_urls, :depth_limit => 0) do |anemone|

		anemone.on_every_page do |page|

			doc = Nokogiri::HTML.parse(page.body.toutf8)

			mainVideo = doc.xpath("//*[@id='mainVideo']")
			player = mainVideo.xpath(".//*[@class='player']")

			title = mainVideo.xpath(".//h1")[0].content
			video_url = player.xpath(".//iframe")[0].attribute('src')

			# コレクションからオブジェクトを抽出
			got_video = video_list.get_video_by_page_url(page.url.to_s)
			# プロパティを設定
			got_video.title = title
			got_video.video_url = video_url.text
		end
	end

	video_list.write_to_db
end

# アゲサゲ
def crawl_agesage

	# Videoオブジェクトを格納する
	video_list = TempVideoList.new()

	root_url = "http://asg.to/new-movie"

	video_page_urls = []

	# 5ページ分の起点URLを作る
	1.times do |num|
		start_url = "#{root_url}?page=#{num+1}"

		puts "url : #{start_url}"

		doc = Nokogiri::HTML(open(start_url))

		nodes = doc.xpath("//div")

		nodes.each do |node|
			div_class = node.attribute('class')
			div_id = node.attribute('id')

			next if not (div_class == nil && div_id == nil)

			a_tag = node.xpath(".//a")[0]
			img_tag = node.xpath(".//img")[0]

			next if a_tag == nil || img_tag == nil

			page_url = a_tag.attribute('href')
			thumbnail_url = img_tag.attribute('src')

			full_path = root_url + page_url.text

			next if page_url == nil

			video_page_urls.push(full_path)

			# オブジェクトを作成
			new_video = TempVideo.new()
			new_video.page_url = full_path
			new_video.thumbnail_url = thumbnail_url.text

			video_list.add_video(new_video)
		end
	end

	Anemone.crawl(video_page_urls, :depth_limit => 0) do |anemone|

		anemone.on_every_page do |page|

			doc = Nokogiri::HTML.parse(page.body.toutf8)

			mainVideo = doc.xpath("//*[@id='centerarea']")
			player = mainVideo.xpath(".//*[@class='player']")

			title = mainVideo.xpath(".//h2")[0].content
			# video_url = player.xpath(".//iframe")[0].attribute('src')

			# コレクションからオブジェクトを抽出
			got_video = video_list.get_video_by_page_url(page.url.to_s)
			# プロパティを設定
			got_video.title = title
			# got_video.video_url = video_url.text

			got_video.print
		end
	end

	# video_list.write_to_db

end

# 再生時間のテキストを解析し分に直して返します。
# 引数：再生時間を表す文字列（例：00:02:55）
def parse_play_time_text(play_time_text)
	# 正規表現
	re = "(\\d\\d):(\\d\\d):(\\d\\d)"

	md = /#{re}/.match(play_time_text)

	return 0 if md.nil?

	hour = md[1].to_i
	minutes = md[2].to_i
	seconds = md[3].to_i

	total_minutes = (hour * 60) + minutes
end
