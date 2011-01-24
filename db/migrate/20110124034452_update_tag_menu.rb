class UpdateTagMenu < ActiveRecord::Migration
  def self.up
    item = MenuItem.find_by_name( "Tags" )
    item.path = "/survey_respondents/tags_admin"
    item.save
  end

  def self.down
  end
end
