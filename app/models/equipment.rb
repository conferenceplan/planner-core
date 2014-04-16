class Equipment < ActiveRecord::Base
  attr_accessible :lock_version, :details, :room_id, :equipment_type_id
end
