class MenuItem < ActiveRecord::Base
  
  belongs_to :menu

  has_many :menu_items
  belongs_to :menu_item
  
  acts_as_taggable

end
