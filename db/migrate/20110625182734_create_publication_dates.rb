class CreatePublicationDates < ActiveRecord::Migration
  def self.up
    create_table :publication_dates do |t|

      t.datetime :timestamp

      t.timestamps
    end
  end

  def self.down
    drop_table :publication_dates
  end
end
