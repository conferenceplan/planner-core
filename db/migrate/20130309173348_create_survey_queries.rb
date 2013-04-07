class CreateSurveyQueries < ActiveRecord::Migration
  def self.up
    create_table :survey_queries do |t|
      
      # Name
      t.string :name
      # Operation
      t.string :operation # indicate whether to ALL or ANY i.e. to AND or OR this with the rest of the queries
      
      # Survey id
      t.integer :survey_id
      
      # Shared
      t.boolean :shared
      # Owner 
		  t.integer :user_id

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :survey_queries
  end
end
