class UsersController < ApplicationController
  before_action :signed_in_user, 
                only: [:edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

	def show
    @user = User.find_by(:uniq_user_name => params[:id])
    @lists = @user.lists.paginate(page: params[:page])
	end

  def new
  	@user = User.new
  end

  def create
  	@user = User.new(user_params)
  	if @user.save

      sign_in @user
  		# 保存の成功をここで扱う。
  		flash[:success] = "Sign Up Success."
  		redirect_to @user
  	else
  	  render 'new'
  	end
  end

  def edit
    @user = User.find_by(:uniq_user_name => params[:id])
  end

  def update
    @user = User.find_by(:uniq_user_name => params[:id])
    if @user.update_attributes(user_params)
      # 更新が成功した場合を扱う
      flash[:success] = "プロフィールを更新しました。"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "ユーザを削除しました！"
    redirect_to user_url
  end

  # フォロー中のリスト一覧を表示
  def following_list
    @user = User.find_by(:uniq_user_name => params[:id])
    @lists = @user.following_lists.paginate(page: params[:page])
    render 'show_follow_lists'
  end

  # ユーザーのビデオリスト一覧を表示
  def lists
    @user = User.find_by(:uniq_user_name => params[:id])
    @lists = @user.lists.paginate(page: params[:page])
    render 'show_lists'
  end

  private

  	def user_params
      params.require(:user).permit(:name, :password,
                                   :password_confirmation,
                                   :uniq_user_name)
    end

    # Before actions

    def correct_user
      @user = User.find_by(:uniq_user_name => params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end

end
