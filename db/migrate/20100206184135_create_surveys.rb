#
# Contains the results of a survey, used for to assist with the scheduling process
#
class CreateSurveys < ActiveRecord::Migration
  def self.up
    create_table :surveys do |t|
      t.references :Person # there is up to one survey per person

      t.text    :notes #free form text from program team about person (additional requests/issues)
      t.boolean :can_interview #if willing to be interviewed by press
      t.boolean :hugo_nominee #if a hugo nominee
      t.boolean :volunteer #if person volunteered for program rather than being invited

      t.datetime :arrival_time #day and time of arrival
      t.datetime :departure_time #day and time of departure
      
      t.integer :max_items
      t.integer :max_items_per_day
      t.integer :nbr_panels_moderated
      
      t.string   :homepage # should this be part of the contact information?

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :surveys
  end
end
