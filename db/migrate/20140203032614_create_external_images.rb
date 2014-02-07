class CreateExternalImages < ActiveRecord::Migration
  def change
    create_table :external_images do |t|
      t.string :picture

      t.column :imageable_id, :integer
      t.column :imageable_type, :string
      t.column :use, :string     

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end
end
