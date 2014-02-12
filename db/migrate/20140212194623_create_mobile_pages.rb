class CreateMobilePages < ActiveRecord::Migration
  def change
    create_table :mobile_pages do |t|
      t.integer :order
      t.string :url
      t.string :title

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end
end
