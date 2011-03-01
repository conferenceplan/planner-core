class AddViewerItemeditorRoles < ActiveRecord::Migration
  def self.up
      Role.create(:title => 'Viewer')
      Role.create(:title => 'Itemeditor')
  end

  def self.down
  end
end
