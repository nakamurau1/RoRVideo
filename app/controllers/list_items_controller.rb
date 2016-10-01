class ListItemsController < ApplicationController
	before_action :signed_in_user

	def destroy

		@list = List.find_by(id: params[:list_item][:list_id])
		@video = Video.find_by(id: params[:list_item][:video_id])
		@videos = @list.videos.paginate(page: params[:page])

		# Listから削除
		@list.toggle(@video)

		respond_to do |format|
        	format.html { redirect_to list }
        	format.js
      	end
	end
	
end