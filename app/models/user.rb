class User < ActiveRecord::Base
  # TODO - validate
  attr_accessible :login, :login_count, :failed_login_count, :current_login_ip, :last_login_ip, :person_id, :password, :password_confirmation

  acts_as_authentic do |c|
    c.logged_in_timeout(2.hours) # set the session timeout
  end
  has_many  :roleAssignments
  has_many  :roles, :through => :roleAssignments
  has_one   :preference
  
  def role_symbols
   (roles || []).map {|r| r.title.to_sym }
  end
  
  def role_strings
   (roles || []).map {|r| r.title }
  end
  
  has_many :survey_queries
end
