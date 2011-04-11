class UpdateScheduleMenu < ActiveRecord::Migration
  def self.up
    item = MenuItem.find_by_name("Schedule")
    item.path = "/program_planner"
    item.save
  end

  def self.down
  end
end
