require 'site_config'

class SetPublicDates < ActiveRecord::Migration
  def up
    
    # for each siteconfig set the public data if not already set
    SiteConfig.all.each do |cfg|
      if cfg.start_date
        if !cfg.public_start_date
          cfg.public_start_date = cfg.start_date
        end
        if !cfg.public_number_of_days || (cfg.public_number_of_days == 0)
          cfg.public_number_of_days = cfg.number_of_days
        end
        cfg.save!
      end
    end
    
  end
end
