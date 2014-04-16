class RoleAssignment < ActiveRecord::Base
  attr_accessible :lock_version, :user_id, :role_id
  belongs_to  :user
  belongs_to  :role
end
