#
#
#
raw_config = File.read(RAILS_ROOT + "/config/siteconfig.yml")
SITE_CONFIG = YAML.load(raw_config)[RAILS_ENV]
