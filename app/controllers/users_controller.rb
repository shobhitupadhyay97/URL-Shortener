class UsersController < ApplicationController
  def index
    if session[:user_id] != nil
        redirect_to urls_path
    end
  end

  def show
  	@user = User.find(params[:id])
  end

  def new
  	@user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the My App!"
      redirect_to urls_path
    else
      render 'new'
    end
  end

  def about
  end

  def help
  end

  def contact
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
