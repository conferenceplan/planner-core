class CreateSurveyQuestions < ActiveRecord::Migration
  def self.up
    create_table :survey_questions do |t|
      t.string :code, { :default => "" }
      t.string :title, { :default => "" }
      t.string :question, { :default => "" }
      t.string :tags_label, { :default => "" }

      t.string :type, { :default => "textfield" } # type of the question...
      # NOTE: we do not have mutliple choice for selection box as yet

      t.integer :additional, { :default => 0 } # for repeating questions i.e. multiple adresses, multiple phone numbers etc.
      t.string :validation, { :default => "" } # name of method to assist with the validation of input

      t.references :SurveyGroup

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :survey_questions
  end
end
