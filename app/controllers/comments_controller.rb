class CommentsController < ApplicationController
  before_action :signed_in_user, only: [:create, :destroy]
  before_action :correct_user, only: :destroy

  def create
    userful_params = micropost_params
    @comment = current_user.comments.build(userful_params)
    if @comment.save
      flash[:success] = "发送成功!"
    else
      flash[:success] = "发送失败"
    end
    redirect_to "/product/show?id=#{userful_params[:product_id]}"
  end
  def destroy
    @comment.destroy
    redirect_to current_user
  end

  private
  def micropost_params
    params.require(:comment).permit(:content, :product_id)
  end

  def correct_user
    @comment = current_user.comments.find_by(id: params[:id])
    redirect_to root_url if @comment.nil?
  end
end
