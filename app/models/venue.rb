class Venue < ActiveRecord::Base
  
  has_many  :rooms
  validates_presence_of :name

  acts_as_audited

end
