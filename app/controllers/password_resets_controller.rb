class PasswordResetsController < ApplicationController
  before_action :get_user,          only: [:edit, :update]
  before_action :valid_user,        only: [:edit, :update]
  before_action :check_expiration,  only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email(request)
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    elsif @user.update_attributes(user_params)
      log_in @user
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Your password has been reset."
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    puts User.find_by(email: params[:email])
    @user = User.find_by(email: params[:email])
  end

  def valid_user
    puts @user
    unless @user && @user.authenticated?(:reset, params[:id])
      puts "REDIRECTING"
      redirect_to root_url
    end
  end

  def check_expiration
    if @user.init_password_valid
      if @user.welcome_password_expired?
        @user.update_attribute(:init_password_valid, false)
        puts "WELCOME EXPIRED"
        flash[:danger] = "Welcome has expired."
        redirect_to new_password_reset_url
      end

    elsif @user.password_reset_expired?
      puts "PASSWORD RESET EXPIRED"
      flash[:danger] = "Password reset has expired."
      redirect_to new_password_reset_url
    else
      puts "ALL EXPIRED"
    end
  end
end


