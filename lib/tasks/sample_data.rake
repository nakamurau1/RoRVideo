namespace :db do
  desc "Fill database with sample user"
  task populate: :environment do

    delete_all_user

    make_users

    # following_lists

    # make_public_lists

  end
end

def delete_all_user

  User.all.each do |u|
    u.destroy!
  end

end

def make_users
  User.create!(uniq_user_name: "rovideo",
               name: "rovideo",
               password: "passwordissimple",
               password_confirmation: "passwordissimple")

  admin = User.create!(uniq_user_name: "admin_webmaster",
                       name: "admin",
                       password: "passwordissimple",
                       password_confirmation: "passwordissimple",
                       admin: true)

end

# def following_lists

#   user = User.first
#   other_user = User.all[1]

#   user.follow_list!(other_user.lists.first)

# end

# def make_public_lists

#   other_user = User.last
#   other_user.lists.create!(name: "清純派", comment: "清純派の動画を集めました！",private: false)

# end
