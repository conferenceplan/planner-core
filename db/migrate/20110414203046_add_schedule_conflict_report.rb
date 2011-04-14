class AddScheduleConflictReport < ActiveRecord::Migration
  def self.up
    menu = MenuItem.find_by_name('Planner Reports')
    MenuItem.create(:name => 'Scheduling Conflicts', :path => "/program_planner/getConflicts", :menu_item => menu)
  end

  def self.down
    MenuItem.find_by_name('Scheduling Conflicts').destroy
  end
end
