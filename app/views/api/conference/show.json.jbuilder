
# TODO - the site config info an tz should be database driven
json.name           SITE_CONFIG[:conference][:name]
json.start_day      Time.zone.parse(SITE_CONFIG[:conference][:start_date]).strftime('%Y-%m-%d')
json.num_days       SITE_CONFIG[:conference][:number_of_days]
json.utc_offset     Time.zone.parse(SITE_CONFIG[:conference][:start_date]).utc_offset/(60*60) # Time.zone.utc_offset/(60*60)
