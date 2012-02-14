class CreateSurveyAnswers < ActiveRecord::Migration
  def self.up
    create_table :survey_answers do |t|
      t.string :code, { :default => "" }
      t.string :answer, { :default => "" }
      t.string :answer_id, { :default => "" }
      t.boolean :default, { :default => false }
      
      t.references :SurveyQuestion

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :survey_answers
  end
end
