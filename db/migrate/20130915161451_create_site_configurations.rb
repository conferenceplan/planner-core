class CreateSiteConfigurations < ActiveRecord::Migration
  def self.up
    create_table :site_configs do |t|
      t.string :captcha_pub_key, { :default => "" }
      t.string :captcha_priv_key, { :default => "" }
      
      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :site_configs
  end
end
