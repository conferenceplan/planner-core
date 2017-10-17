#
#
#

# Used to get and set the available locales for planner and sites
module UISettingsService
  def self.getSiteLanguages
    %w[en fr]
  end

  def self.getLanguages
    setting = UserInterfaceSetting.where(key: 'languages').first
    if setting
      setting.value
    else
      %w[en fr]
    end
  end

  def self.getAllowedLanguages
    # This will grow as we allow more languages for the Site UI
    %w[en fr pl]
  end

  def self.getDefaultLocale
    getLanguages.first
  end

  def self.default_site_locale
    getSiteLanguages.first
  end

  def self.getLanguages_sym
    res = getLanguages
    res.collect(&:to_sym)
  end

  def self.setLanguages(value)
    setting = UserInterfaceSetting.first_or_initialize(key: 'languages')
    setting._value = Marshal.dump(value)
    setting.save!
  end
end
