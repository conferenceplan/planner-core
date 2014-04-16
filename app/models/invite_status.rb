class InviteStatus < Enum
  attr_accessible :lock_version, :name, :position
  
  acts_as_enumerated

end
