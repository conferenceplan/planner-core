#
#
#

module UISettingsService
  
  def self.getLanguages
    
    setting = UserInterfaceSetting.first :conditions => {:key => 'languages'}
    setting.value
    
  end
  
  def self.setLanguages(value)
    
    setting = UserInterfaceSetting.first :conditions => {:key => 'languages'}
    setting._value = Marshal.dump(value)
    setting.save!
    
  end
  
end
