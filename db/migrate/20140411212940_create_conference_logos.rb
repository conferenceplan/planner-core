class CreateConferenceLogos < ActiveRecord::Migration
  def change
    create_table :conference_logos do |t|
      t.string :image

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end
end
