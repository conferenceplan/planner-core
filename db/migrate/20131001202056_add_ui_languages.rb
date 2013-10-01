class AddUiLanguages < ActiveRecord::Migration
  def up
    
    setting = UserInterfaceSetting.new :key => "languages", :_value => Marshal.dump(['en', 'fr'])
    setting.save!
    
  end

  def down
  end
end
