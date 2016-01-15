module ProductHelper
  def show
    name = get_name[:name]
    if !name.nil?
      @product = Product.find_by_name name
      @bad_comments = @product.bad_comments
    end
  end

  private
  def get_name
    params.require(:name).permit :name
  end
end
