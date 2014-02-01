#
#
#
raw_config = File.read("config/siteconfig.yml")
SITE_CONFIG = YAML.load(raw_config)[Rails.env] #Time.use_zone('Eastern Time (US & Canada)') { YAML.load(raw_config)[Rails.env] }

unless ENV['NODAEMON']
  cfg = SiteConfig.find :first # for now we only have one convention... change when we have many (TODO)
  if (cfg) # TODO - temp, to be replaced in other code
    SITE_CONFIG[:conference][:name] = cfg.name
    SITE_CONFIG[:conference][:number_of_days] = cfg.number_of_days
    SITE_CONFIG[:conference][:start_date] = cfg.start_date
    SITE_CONFIG[:conference][:time_zone] = cfg.time_zone
  end
end
