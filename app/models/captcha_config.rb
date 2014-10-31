class CaptchaConfig < ActiveRecord::Base
  attr_accessible :lock_version, :captcha_pub_key, :captcha_priv_key
end
