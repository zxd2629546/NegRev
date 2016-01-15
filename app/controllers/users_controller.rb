class UsersController < ApplicationController
  before_action :signed_in_user, only: [:edit, :update]
  before_action :correct_user, only: [:edit, :update]

  def new
    @user = User.new
  end
  def index
    @users = User.paginate(page: params[:page], per_page: 16)
  end
  def show
    @user = User.find(params[:id])
    @comments = @user.comments.paginate(page: params[:page], per_page: 10)
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "个人资料更新成功"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "欢迎来到差评网!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "用户删除完成."
    redirect_to users_url
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
# Before filters
  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: "请先登录."
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end
end