class AddSortToSurveyAnswer < ActiveRecord::Migration
  def change
     add_column :sort_order, :survey_answers, :integer, { :default => 0 }
  end
end
