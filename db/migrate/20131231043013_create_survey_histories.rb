class CreateSurveyHistories < ActiveRecord::Migration
  def change
    create_table :survey_histories do |t|
      
      # survey respondent details
      t.column    :survey_respondent_detail_id, :integer
      # date when the survey was filled
      t.column    :filled_at, :datetime
      # which survey
      t.column    :survey_id, :integer

      t.timestamps
    end
  end
end
