class CreateSurveyGroups < ActiveRecord::Migration
  def self.up
    create_table :survey_groups do |t|
      t.string :code, { :default => "" }
      t.string :name, { :default => "" }
      t.string :altname, { :default => "" }
      t.string :description, { :default => "" }

      t.references :survey

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :survey_groups
  end
end
