class Schedule < ActiveRecord::Base
  
  has_many  :time_slots

  acts_as_audited

end
