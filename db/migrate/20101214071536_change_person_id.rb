class ChangePersonId < ActiveRecord::Migration
  def self.up
        remove_column :survey_respondents, :person_id
        add_column :survey_respondents, :person_id, :integer

  end

  def self.down
  end
end
