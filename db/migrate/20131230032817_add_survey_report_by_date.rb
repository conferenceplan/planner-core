class AddSurveyReportByDate < ActiveRecord::Migration
  def change
    add_column :survey_queries, :date_order, :boolean, { :default => 0 }
  end
end
