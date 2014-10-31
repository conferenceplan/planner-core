class CreateCaptchaConfigs < ActiveRecord::Migration
  def change
    create_table :captcha_configs do |t|
      t.string :captcha_pub_key, { :default => "" }
      t.string :captcha_priv_key, { :default => "" }

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end
end
