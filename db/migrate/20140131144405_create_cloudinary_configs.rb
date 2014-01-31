class CreateCloudinaryConfigs < ActiveRecord::Migration
  def change
    create_table :cloudinary_configs do |t|
      t.string :cloud_name
      t.string :api_key
      t.string :api_secret
      t.boolean :enhance_image_tag
      t.boolean :static_image_support

      t.timestamps
    end
  end
end
