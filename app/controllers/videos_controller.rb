class VideosController < ApplicationController

	def index
		# @all_videos = Video.get_new_videos.paginate(page: params[:page]

		# ransackで検索できるように修正
		@search = Video.search(params[:q])
	    # 新着順にソート
	    @search.sorts = ['created_at desc'] if @search.sorts.empty?
	    # xvideoは表示対象から除外
    	@all_videos = @search.result(distinct: true).paginate(page: params[:page])
	end

	def create
		@comments = []
	end

	def show
		@video = Video.find_by(:id => params[:id])
		@video.count_up()
      	@comment_items = @video.video_comments.paginate(page: params[:page])
      	@favorites_items = current_user.lists if signed_in?
	end

	# ランダムに動画ページにリダイレクトします。
	def shuffle
		offset = rand(Video.count)

		random_record = Video.offset(offset).first

		redirect_to video_path(random_record)
	end
end