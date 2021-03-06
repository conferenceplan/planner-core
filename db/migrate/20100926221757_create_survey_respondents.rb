class CreateSurveyRespondents < ActiveRecord::Migration
  def self.up
    create_table :survey_respondents do |t|
      t.string :first_name, { :default => "" }
      t.string :last_name, { :default => "" }
      t.string :prefix, { :default => "" }
      t.string :key # a key created by the committee to identify the person taking the survey

      t.string    :persistence_token,   :null => false                # required
      t.string    :single_access_token, :null => false                # for access via token for survey

      t.references :Person # eventually there is one person/participant per survey
      
      t.timestamps
    end
  end

  def self.down
    drop_table :survey_respondents
  end
end
