class CreateSurveyQueryPredicates < ActiveRecord::Migration
  def self.up
    create_table :survey_query_predicates do |t|
      
      # The query that this question is part of
      t.integer :survey_query_id
      t.boolean :ored # indicate whether to AND or OR this with the rest of the queries
      
      # Survey group id
      t.integer :survey_group_id
      # Survey question id
      t.integer :survey_question_id
      # Operator (contains, does not contain, = , !=)
      t.string :operator
      # Value
      t.string :value

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :survey_query_conditions
  end
end
