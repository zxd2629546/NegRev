class ChangeProductIdForBadComment < ActiveRecord::Migration
  def change
    rename_column :bad_comments, :products_id, :product_id
  end
end
