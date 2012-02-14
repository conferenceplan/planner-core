class InitialSurveyStructure < ActiveRecord::Migration
  def self.up
    # First get rid of the stuff that we do not use
    remove_column :surveys, :person_id
    remove_column :surveys, :notes
    remove_column :surveys, :can_interview
    remove_column :surveys, :hugo_nominee
    remove_column :surveys, :volunteer
    remove_column :surveys, :arrival_time
    remove_column :surveys, :departure_time
    remove_column :surveys, :max_items
    remove_column :surveys, :max_items_per_day
    remove_column :surveys, :nbr_panels_moderated
    remove_column :surveys, :homepage
    
    # Then add in the columns we need to support the actual survey structure
		add_column :surveys, :name, :string
    add_column :surveys, :welcome, :string
    add_column :surveys, :thank_you, :string
  end

  def self.down
		remove_column :surveys, :name
    remove_column :surveys, :welcome
    remove_column :surveys, :thank_you
  end
end
