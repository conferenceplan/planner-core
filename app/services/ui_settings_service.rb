#
#
#

module UISettingsService

  def self.getLanguages

    setting = UserInterfaceSetting.first :conditions => {:key => 'languages'}
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
