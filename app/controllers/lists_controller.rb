class ListsController < ApplicationController
  before_action :signed_in_user, only: [:create, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]

  # 公開マイリストの一覧を表示
  def index
    @all_lists = List.where(private: false).paginate(page: params[:page])
  end

  # リストの中身を観る
  def show

  	@list = List.find_by(:id => params[:id])

    if !current_user?(@list.user) && @list.private?
      # カレントユーザがリストの所有者でなく、リストが非公開の場合

      redirect_to root_path
    end

    @videos = @list.videos.paginate(page: params[:page])
  end

  # マイリスト作成ボタンが押された
  def new
    @list = List.new
  end

  def create
    @user = current_user

    @list = current_user.lists.build(list_params)

    if @list.save
      flash[:success] = "新しいリストを作成しました"

      redirect_to lists_user_path(@user)
    else
      # 失敗した時
      render 'new'
    end
  end

  # リストを削除
  def destroy
    @list = List.find(params[:id])
    @list.destroy

    @user = @list.user
    @lists = @user.lists.paginate(page: params[:page])

    respond_to do |format|
      format.html { redirect_to lists_user_path(@user) }
      format.js
    end
  end

  # マイリストの編集ページに移動
  def edit
    @list = List.find(params[:id])
  end

  # マイリストを更新
  def update
    @list = List.find(params[:id])
    if @list.update_attributes(list_params)
      # 更新が成功した場合を扱う
      flash[:success] = "マイリストを更新しました。"
      redirect_to @list
    else
      render 'edit'
    end
  end

  # 動画ページでリストに追加された時
  def toggle

    # テンプレートを使わないことを明示的に宣言
    render nothing: true

    # 動画を追加する対象のListを取得
    @list = List.find(params[:list_id])

    # 追加する動画を取得
    @video = Video.find(params[:video_id])

    # Listに動画を追加する。もし既に追加されている場合は除外する。
    @list.toggle(@video)

  end

  private

    def list_params
      params.require(:list).permit(:name,:followers_count, :comment, :private)
    end

    # Before actions

    def correct_user
      @list = List.find(params[:id])
      redirect_to(root_path) unless current_user?(@list.user)
    end

end
