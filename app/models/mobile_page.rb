class MobilePage < ActiveRecord::Base
  attr_accessible :order, :title, :url
  audited
end
