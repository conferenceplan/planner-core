class ThemeRemoveImage < ActiveRecord::Migration
  def up
     remove_column :mobile_themes, :default_bio_image
  end

  def down
    add_column :mobile_themes, :default_bio_image, :string
  end
end
