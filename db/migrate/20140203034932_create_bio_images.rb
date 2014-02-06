class CreateBioImages < ActiveRecord::Migration
  def change
    create_table :bio_images do |t|
      t.string :bio_picture

      t.column :person_id, :integer

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end
end
