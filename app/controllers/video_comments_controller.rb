class VideoCommentsController < ApplicationController
  before_action :signed_in_user

  def create
  	@comment = current_user.video_comments.build(video_comment_params)
    @video = Video.find_by(:id => params[:video_comment][:video_id])

    if @comment.save
      # flash[:success] = "Comment created!"

      @comment_items = @video.video_comments.paginate(page: params[:page])

      respond_to do |format|
        format.html { redirect_to root_url }
        format.js
      end
    else
      render 'static_pages/home'
    end
  end

  # コメントを削除
  def destroy
    @comment = VideoComment.find(params[:id])
    @comment.destroy

    @video = @comment.video
    @comment_items = @video.video_comments.paginate(page: params[:page])

    respond_to do |format|
      format.html { redirect_to @comment.video }
      format.js
    end
  end

  private

    def video_comment_params
      params.require(:video_comment).permit(:video_id,:comment)
    end

end
