class AddContextReport < ActiveRecord::Migration
  def self.up
     MenuItem.create(:name => "Participant Tags by Context", :path => "/survey_reports/tags_by_context", :menu_item => MenuItem.find_by_name("Survey Reports"))
  end

  def self.down
     MenuItem.find_by_name("Participant Tags by Context").destroy
  end
end
