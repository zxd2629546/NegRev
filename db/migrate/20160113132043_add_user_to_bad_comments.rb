class AddUserToBadComments < ActiveRecord::Migration
  def change
    add_reference :bad_comments, :user, index: true, foreign_key: true
  end
end
