class Survey < ActiveRecord::Base
  belongs_to  :Person

  has_many    :Answer
  
end
