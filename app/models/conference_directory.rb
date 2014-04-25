class ConferenceDirectory < ActiveRecord::Base
  attr_accessible :lock_version, :name, :code, :endpoint, :description
  # TODO - add in capabilities (and default these if not set in DB...)
end
