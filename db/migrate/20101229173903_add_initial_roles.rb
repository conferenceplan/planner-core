class AddInitialRoles < ActiveRecord::Migration
  def self.up
       Role.create(:title => 'Planner')
       Role.create(:title => 'Admin')
       Role.create(:title => 'TagAdmin')
  end

  def self.down
  end
end
