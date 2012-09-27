class CreateSurveyRespondentDetails < ActiveRecord::Migration
  def self.up
    create_table :survey_respondent_details do |t|
      # The name of the respondent
      # NOTE: consider single field input, but for now two fields because of the previous structure...
      t.string :first_name, { :default => "" }
      t.string :last_name, { :default => "" }
      t.string :suffix, { :default => "" }

      # The pen-name/pseudonym...
      
      # Email address
      t.string :email, { :default => "" }
      
      #
      t.references :survey_respondent # match to the actual respondent if there is one

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :survey_respondent_details
  end
end
