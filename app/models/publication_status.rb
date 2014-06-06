class PublicationStatus < ActiveRecord::Base
  attr_accessible :status, :submit_time, :lock_version
  
  validates_inclusion_of :status, :in => [:inprogress, :completed]
  
  def status
    read_attribute(:status).to_sym
  end
  
  def status= (value)
    write_attribute(:status, value.to_s)
  end
end
