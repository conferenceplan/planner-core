require 'site_config'
require 'captcha_config'

class MigrateCaptchaConfigs < ActiveRecord::Migration
  def up
    # move the captcha info into the new captcha config
    cfgs = SiteConfig.all
    cfgs.each do |cfg|
      captcha = CaptchaConfig.new(captcha_pub_key: cfg.captcha_pub_key, captcha_priv_key: cfg.captcha_priv_key)
      captcha.save!
    end
  end
end
