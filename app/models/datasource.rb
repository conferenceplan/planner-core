class Datasource < ActiveRecord::Base
  has_many :peoplesources
  has_many :people, :through => :peoplesources
  before_destroy :check_not_in_use
  
  def check_not_in_use  
    if (self.name == 'Application')
        self.errors.add(:base,"Cannot delete Application datasource")
        return false
    else
      if (peoplesources.nil?)
        self.errors.add(:base,"Cannot delete datasource once people have been imported")
        return false
      else
        return true
      end
    end
  end
  
  
end
