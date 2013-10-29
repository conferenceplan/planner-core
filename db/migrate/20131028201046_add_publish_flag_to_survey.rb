class AddPublishFlagToSurvey < ActiveRecord::Migration
  
  def change
    add_column :surveys, :public, :boolean
    add_column :surveys, :authenticate, :boolean
  end

end
