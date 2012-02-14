class CreateSurveyAssignments < ActiveRecord::Migration
  def self.up
    create_table :survey_assignments do |t|
      t.references :SurveyResponse
      t.references :Person

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :survey_assignments
  end
end
