class ThemeName < ActiveRecord::Base
  attr_accessible :lock_version, :name
  
  has_many :themes, :dependent => :destroy
end
