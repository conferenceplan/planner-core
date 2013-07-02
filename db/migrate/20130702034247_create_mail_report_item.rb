class CreateMailReportItem < ActiveRecord::Migration
  def self.up
     partMenu = MenuItem.all(:conditions => { :name => "Communications" } ).first
     MenuItem.create( :name => "Mailing History", :path => "/reports/mail_reports", :menu_item => partMenu)
  end

  def self.down
     MenuItem.find_by_name("Mailing History").destroy
  end
end
