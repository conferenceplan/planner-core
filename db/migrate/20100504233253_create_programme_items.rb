class CreateProgrammeItems < ActiveRecord::Migration
  def self.up
    create_table :programme_items do |t|
      t.string :short_title
      t.string :title
      t.text :precis
      t.integer :duration #in minutes
      t.integer :minimum_people
      t.integer :maximum_people
      t.string :format #TODO: change to a type
      t.text :notes
      t.boolean :print
      t.references :time_slot
#      t.item_number :string #because
# TODO: add list of equipment needed

      t.integer :room_id

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :programme_items
  end
end
