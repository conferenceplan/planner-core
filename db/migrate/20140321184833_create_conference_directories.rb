class CreateConferenceDirectories < ActiveRecord::Migration
  def change
    create_table :conference_directories do |t|
      t.string :name
      t.string :code,         :limit => 10
      t.string :endpoint,     :limit => 300
      t.string :description,  :limit => 2000

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end
end
