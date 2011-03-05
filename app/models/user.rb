class User < ActiveRecord::Base
  acts_as_authentic do |c|
    c.logged_in_timeout(15.minutes) # set the session timeout
  end
  has_many  :roleAssignments
  has_many  :roles, :through => :roleAssignments
  def role_symbols
   (roles || []).map {|r| r.title.to_sym}
  end
end
