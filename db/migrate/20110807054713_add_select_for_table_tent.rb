class AddSelectForTableTent < ActiveRecord::Migration
  def self.up
     item = MenuItem.find_by_name("Create CSV for Table Tents")
     item.path = '/planner_reports/selectTableTents'
     item.save
  end

  def self.down
     item = MenuItem.find_by_name("Create CSV for Table Tents")
     item.path = '/planner_reports/selectTableTents'
     item.save
  end
end
