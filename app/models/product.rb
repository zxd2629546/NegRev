class Product < ActiveRecord::Base
  has_many :bad_comments
  has_many :comments
end
