class SurveyAddCaptchOption < ActiveRecord::Migration
  def self.up
    add_column :surveys, :use_captcha, :boolean, { :default => 0 }
  end

  def self.down
    remove_column :surveys, :use_captcha
  end
end
