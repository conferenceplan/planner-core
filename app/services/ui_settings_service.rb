#
#
#

module UISettingsService
  
  def self.getSiteLanguages
    ['en','fr']
  end

  def self.getLanguages

    setting = UserInterfaceSetting.where({:key => 'languages'}).first
    if setting
      setting.value
    else
      ['en','fr']
    end
  end

  def self.setLanguages(value)

    setting = UserInterfaceSetting.first_or_initialize({key: 'languages'})
    setting._value = Marshal.dump(value)
    setting.save!

  end

end
