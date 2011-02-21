class CreateSurveyCopyStatuses < ActiveRecord::Migration
  def self.up
    create_table :survey_copy_statuses do |t|
      t.references :person
      t.references :survey_respondents
      t.boolean :nameCopied, { :default => false }
      t.boolean :pseudonymCopied, { :default => false }
      t.boolean :addressCopied, { :default => false }
      t.boolean :phoneCopied, { :default => false }
      t.boolean :emailCopied, { :default => false }

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
  end
end
