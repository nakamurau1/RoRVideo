class User < ActiveRecord::Base
    has_many :lists, dependent: :destroy
    has_many :video_comments, dependent: :destroy
    has_many :followed_lists, dependent: :destroy
    has_many :following_lists, through: :followed_lists, source: :list
	  before_create :create_remember_token
	  validates :name, presence: true, length: {maximum: 50}
    has_secure_password
    validates :password, length: { minimum: 6 }
    validates :uniq_user_name,
      presence: true, uniqueness: {case_sensitive: false},
      length: { minimum: 3, maximum: 25}
      # format: { with: /^[A-Za-z][\w-]*$/ }
      # → なんかわからんけどエラー出るのでコメントアウト
    after_create :create_mylist

    # URLのid部分にid以外のものを指定する
    # http://railsdoc.com/references/to_param
    def to_param
        uniq_user_name
    end

    def User.new_remember_token
    	SecureRandom.urlsafe_base64
    end

    def User.encrypt(token)
    	Digest::SHA1.hexdigest(token.to_s)
    end

    # ユーザが引数のリストをフォローしているか確認します
    def following_list?(list)
        self.followed_lists.find_by(list_id: list.id)
    end

    # リストをフォローする
    def follow_list!(list)
        self.followed_lists.create!(list_id: list.id)

        # Listのfollowers_countをカウントアップする
        @list = List.find_by(id: list.id)
        @list.followers_count += 1
        @list.save
    end

    # リストをアンフォローする
    def unfollow_list!(list)
        self.followed_lists.find_by(list_id: list.id).destroy

        # Listのfollowers_countをカウントダウンする
        @list = List.find_by(id: list.id)
        @list.followers_count -= 1
        @list.save
    end

    # ユーザーがフォローしているリストに追加れたビデオの一覧を返します
    def get_videos_in_following_lists
        lists = self.following_lists
        videos = []

        lists.each do |list|
            videos << list.videos
        end

        # フラット化する
        videos.flatten!

        videos
    end

    private

    	def create_remember_token
    		self.remember_token = User.encrypt(User.new_remember_token)
    	end

        # ユーザを新規作成したタイミングでマイリストも作成します
        def create_mylist
            self.lists.create!(name: "マイリスト", private: true)
        end

end
