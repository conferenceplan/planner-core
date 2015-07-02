class CategoryName < ActiveRecord::Base
  attr_accessible :lock_version, :name
  
  has_many :categories, :dependent => :destroy
end
