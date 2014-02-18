class AddAuthMessageToSurvey < ActiveRecord::Migration
  def change
     add_column :surveys, :authenticate_msg, :text
  end
end
