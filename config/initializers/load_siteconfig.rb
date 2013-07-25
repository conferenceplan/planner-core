#
#
#
raw_config = File.read("config/siteconfig.yml")
SITE_CONFIG = YAML.load(raw_config)[Rails.env] #Time.use_zone('Eastern Time (US & Canada)') { YAML.load(raw_config)[Rails.env] }
# Fix time zone?
