class SiteConfig < ActiveRecord::Base
  attr_accessible :lock_version, :name, :time_zone, :start_date, :number_of_days  
  attr_accessor :tz_offset

  before_save :adjust_timezone

  def adjust_timezone
    Time.use_zone(self.time_zone) do 
      day = self.start_date.day
      self.start_date = self.start_date.in_time_zone.change({:day => day, :hour => 0 , :min => 0 , :sec => 0 })
      self.start_date = self.start_date.change({:hour => 0 , :min => 0 , :sec => 0 })
      self.tz_offset = self.start_date.utc_offset/(60*60)
    end
  end

end
