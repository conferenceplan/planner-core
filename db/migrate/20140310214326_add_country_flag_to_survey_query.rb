class AddCountryFlagToSurveyQuery < ActiveRecord::Migration
  def change
     add_column :survey_queries, :show_country, :boolean, { :default => false }
  end
end
