class AddDeclinedMessageToSurvey < ActiveRecord::Migration
  def change
     add_column :surveys, :declined_msg, :text
  end
end
