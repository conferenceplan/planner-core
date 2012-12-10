class AddEmailTemplateMenus < ActiveRecord::Migration
  def self.up
     MenuItem.create(:name => "Mail Config", :path => "/mail_configs", :menu_item => MenuItem.find_by_name("Admin"))
     MenuItem.create(:name => "Manage Mail Templates", :path => "/mail_templates", :menu_item => MenuItem.find_by_name("Admin"))
     MenuItem.create(:name => "Email Reports", :path => "/emailreports", :menu_item => MenuItem.find_by_name("Admin"))
  end

  def self.down
      MenuItem.find_by_name("Mail Config").destroy
      MenuItem.find_by_name("Manage Mail Templates").destroy
      MenuItem.find_by_name("Email Reports").destroy
  end
end
