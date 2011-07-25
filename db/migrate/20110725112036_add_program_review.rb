class AddProgramReview < ActiveRecord::Migration
  def self.up
     MenuItem.create(:name => "Review", :path => "/publisher/review", :menu_item => MenuItem.find_by_name("Schedule"))
  end

  def self.down
      MenuItem.find_by_name("Review").destroy
  end
end
