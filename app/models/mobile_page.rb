class MobilePage < ActiveRecord::Base
  attr_accessible :position, :title, :url
  audited
end
