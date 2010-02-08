class Venue < ActiveRecord::Base
  
  has_many  :rooms
  
end
