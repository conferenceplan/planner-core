class CreateDefaultBioImages < ActiveRecord::Migration
  def change
    create_table :default_bio_images do |t|
      t.string :image

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end
end
