class ChangeSurveyCacheSize < ActiveRecord::Migration
  def self.up
    change_column :smerf_forms, :cache, :text, :limit => 100000
  end

  def self.down
  end
end
