require 'pry'

class StaticPagesController < ApplicationController

  def home

    # 新着動画一覧を取得
    @all_videos = Video.get_new_videos.paginate(page: params[:page])
    @videos_in_following_lists = current_user.get_videos_in_following_lists.paginate(page: params[:page]) if signed_in?

    # ransackで検索できるように修正
    @search = Video.search(params[:q])
    # 新着順にソート
    @search.sorts = ['created_at desc'] if @search.sorts.empty?
    @all_videos = @search.result(distinct: true).paginate(page: params[:page])

    @videos_in_following_lists ||= @all_videos

  end

  def about
  end

  def contact
  end

end
