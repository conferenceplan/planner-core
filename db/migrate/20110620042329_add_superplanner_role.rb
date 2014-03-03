require 'role'

class AddSuperplannerRole < ActiveRecord::Migration
  def self.up
    Role.create(:title => 'SuperPlanner')
  end

  def self.down
  end
end
