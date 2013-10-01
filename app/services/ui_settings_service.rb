#
#
#

module UISettingsService
  
  def self.getLanguages
    
    setting = UserInterfaceSetting.first :conditions => {:key => 'languages'}
    setting.value
    
  end
  
end
