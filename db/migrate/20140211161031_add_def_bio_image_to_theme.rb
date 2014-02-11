class AddDefBioImageToTheme < ActiveRecord::Migration
  def change
    add_column :mobile_themes, :default_bio_image, :string
  end
end
