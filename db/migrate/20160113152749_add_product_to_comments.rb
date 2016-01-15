class AddProductToComments < ActiveRecord::Migration
  def change
    add_reference :comments, :product, index: true, foreign_key: true
  end
end
