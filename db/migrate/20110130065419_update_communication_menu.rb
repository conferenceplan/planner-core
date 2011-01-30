class UpdateCommunicationMenu < ActiveRecord::Migration
  def self.up
     communicationMenu = MenuItem.all(:conditions => { :name => "Communications" } ).first
     MenuItem.create( :name => "Report Invitation Status", :path => "/participants/ReportInviteStatus", :menu_item => communicationMenu)
  end

  def self.down
  end
end
