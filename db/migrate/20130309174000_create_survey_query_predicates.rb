class CreateSurveyQueryPredicates < ActiveRecord::Migration
  def self.up
    create_table :survey_query_predicates do |t|
      
      # Survey question id
      t.integer :survey_question_id
      # Operator (contains, does not contain, = , !=)
      t.string :operation
      # Value
      t.string :value
      
      # Query that this predicate belongs to 
      t.integer :survey_query_id

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :survey_query_predicates
  end
end
