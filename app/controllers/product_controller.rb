class ProductController < ApplicationController
  def show
    @absoulte = false
    @comment = Comment.new
    product_id = params[:id]
    if product_id.nil?
      redirect_to root_path
    else
      begin
        @product = Product.find product_id
      rescue

      end
      if @product.nil?
        redirect_to root_path
      else
        @comments = (@product.bad_comments + @product.comments)
      end
    end
  end

  private
  def min x, y
    return x if x > y
    return y
  end
end
