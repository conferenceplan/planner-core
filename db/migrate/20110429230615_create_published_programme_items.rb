#
# This is the published version of the program item
#
class CreatePublishedProgrammeItems < ActiveRecord::Migration
  def self.up
    create_table :published_programme_items do |t|
      t.string  :short_title
      t.string  :title
      t.text    :precis
      t.integer :duration
      t.string  :format
      
      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end
  
  def self.down
    drop_table :published_programme_items
  end
end

# NOTE: also need room and people assignments to be published
# but do we need people and rooms as well? (safer option would be yes)