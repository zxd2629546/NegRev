class CreateBadComments < ActiveRecord::Migration
  def change
    create_table :bad_comments do |t|
      t.string :name
      t.date :release_time
      t.text :content
      t.references :products, index: true
      t.timestamps null: false
    end
  end
end
