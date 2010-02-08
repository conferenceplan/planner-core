class Term < ActiveRecord::Base
  
  has_many  :tags, :as => :tagable, :dependent => :destroy
  
end
