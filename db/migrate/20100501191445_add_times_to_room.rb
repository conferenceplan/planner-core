class AddTimesToRoom < ActiveRecord::Migration
  def self.up
      add_column :rooms, :survey_id, :integer
  end

  def self.down
      remove_column :rooms, :survey_id
  end
end
