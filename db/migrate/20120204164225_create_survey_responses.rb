class CreateSurveyResponses < ActiveRecord::Migration
  def self.up
    create_table :survey_responses do |t|
      t.references :Person      # id of person that is the respondent
      t.references :Survey      # id of surveyin which the question is found
      t.references :SurveyQuestion # id of question that this is a response to
      t.string :response, { :default => "" }      # response

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :survey_responses
  end
end
