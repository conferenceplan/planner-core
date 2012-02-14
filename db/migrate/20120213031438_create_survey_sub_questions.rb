class CreateSurveySubQuestions < ActiveRecord::Migration
  def self.up
    create_table :survey_sub_questions do |t|
      t.boolean :first, {:default => false}
      t.references :SurveyQuestion
      t.references :SurveyAnswer

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :survey_sub_questions
  end
end
