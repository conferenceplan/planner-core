class CreateThemeNames < ActiveRecord::Migration
  def change
    create_table :theme_names do |t|
      t.string  :name

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end
end
