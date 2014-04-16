class ConferenceDirectory < ActiveRecord::Base
  attr_accessible :lock_version, :name, :code, :endpoint, :description
end
