class SessionsController < ApplicationController

	def new
	end

	def create
		user = User.find_by(uniq_user_name: params[:session][:uniq_user_name].downcase)
		if user && user.authenticate(params[:session][:password]) 
			# ユーザーをサインインさせ、ユーザーページにリダイレクトする。
			sign_in user
			redirect_back_or user
		else
			flash.now[:error] = 'Invalid id/password combination'
			render 'new'
		end
	end

	def destroy
		sign_out
		redirect_to root_url
	end

end
