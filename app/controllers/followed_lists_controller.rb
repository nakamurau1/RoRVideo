class FollowedListsController < ApplicationController
	before_action :signed_in_user

	# フォロー
	def create
		@list = List.find_by(id: params[:followed_list][:list_id])

		# 全リストを取得
	    @all_lists = List.paginate(page: params[:page])

		current_user.follow_list!(@list)
		respond_to do |format|
			format.html {redirect_to @list}
			format.js #⇛ create.js.erbを呼び出す
		end
	end

	# アンフォロオー
	def destroy
		@list = FollowedList.find(params[:id]).list

		# 全リストを取得
	    @all_lists = List.paginate(page: params[:page])

	    @lists = current_user.following_lists.paginate(page: params[:page])
		current_user.unfollow_list!(@list)
		respond_to do |format|
			format.html {redirect_to @list}
			format.js #⇛ destroy.js.erbを呼び出す
		end
	end
end