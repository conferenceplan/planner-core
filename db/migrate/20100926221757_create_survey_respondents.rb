class CreateSurveyRespondents < ActiveRecord::Migration
  def self.up
    create_table :survey_respondents do |t|
      t.string :first_name, { :default => "" }
      t.string :last_name, { :default => "" }
      t.string :suffix, { :default => "" }

      t.string    :persistence_token,   :null => false                # required
      t.string    :single_access_token, :null => false                # for access via token for survey

      t.timestamps
    end
  end

  def self.down
    drop_table :survey_respondents
  end
end
