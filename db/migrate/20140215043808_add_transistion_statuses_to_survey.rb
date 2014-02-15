class AddTransistionStatusesToSurvey < ActiveRecord::Migration
  def change
     add_column :surveys, :accept_status_id, :integer
     add_column :surveys, :decline_status_id, :integer
  end
end
