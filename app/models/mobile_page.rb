class MobilePage < ActiveRecord::Base
  attr_accessible :position, :title, :url, :lock_version
  audited
end
