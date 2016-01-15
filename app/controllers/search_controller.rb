class SearchController < ApplicationController
  def index
    @is_home = true
    query = params["query"]
    if !(query.nil? or query.gsub(/\s/, '').nil?)
      query.gsub!(/\s/, '')
      @products = Product.find_by_sql "select id, name from products where name like '%#{query}%'"
      if @products.size != 1
        if @products.size == 0
          flash[:warn] = "没有匹配项，请重新输入"
        end
        render search_index_path
      else
        redirect_to "/product/show?id=#{@products.id}"
      end
    end
  end
end
