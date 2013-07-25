class UserSession < Authlogic::Session::Base
  self.logout_on_timeout = true
  
  def to_key
     new_record? ? nil : [ self.send(self.class.primary_key) ]
  end
  
  def persisted?
    false
  end
end