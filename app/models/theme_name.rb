class ThemeName < ActiveRecord::Base
  attr_accessible :lock_version, :name

  has_many :themes, :dependent => :destroy

  def published_programme_item_ids
    themes.for_pub_programme_items.pluck(:themed_id)
  end
end
