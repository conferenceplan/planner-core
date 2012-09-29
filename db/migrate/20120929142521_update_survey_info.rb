class UpdateSurveyInfo < ActiveRecord::Migration
  def self.up
    add_column :surveys, :header_image, :string, { :default => "" }
  end

  def self.down
    remove_column :surveys, :header_image
  end
end
