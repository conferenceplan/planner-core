class PersonConstraints < ActiveRecord::Base
  attr_accessible :max_items_per_con, :max_items_per_day, :person_id
  
  belongs_to :person
end
