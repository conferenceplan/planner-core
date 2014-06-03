class CreateContentImages < ActiveRecord::Migration
  def change
    create_table :content_images do |t|
      t.string :picture
      t.string :gallery

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
    add_index :content_images, :gallery
  end
end
