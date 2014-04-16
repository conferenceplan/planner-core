class Enum < ActiveRecord::Base
  # acts_as_enumerated
  self.table_name = "enumrecord"

  attr_accessible :name, :position
end
