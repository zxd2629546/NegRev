class ChangeTypeForCommentContent < ActiveRecord::Migration
  def change
    change_column :comments,  :content, :text
  end
end
