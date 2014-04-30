class UpdateSurveyRespondent < ActiveRecord::Migration
  def up
    # remove not null restriction
    execute "ALTER TABLE `survey_respondents` modify column `single_access_token` varchar(255)"
    remove_column :survey_respondents, :persistence_token
  end

  def down
    add_column :survey_respondents, :persistence_token, :string
  end
end
