class Survey < ActiveRecord::Base
  belongs_to  :person

  has_many    :answers
  
end
