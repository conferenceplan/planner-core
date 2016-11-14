class SiteConfig < ActiveRecord::Base
  attr_accessible :lock_version, :name, :time_zone, :print_time_format,
                  :start_date, :number_of_days,
                  :public_start_date, :public_number_of_days

  attr_accessor :tz_offset

  before_save :adjust_timezone, :check_public_dates

  def adjust_timezone
    Time.use_zone(self.time_zone) do 
      day = self.start_date.day
      month = self.start_date.month
      self.start_date = self.start_date.in_time_zone.change({:day => day, :month => month, :hour => 0 , :min => 0 , :sec => 0 })
      self.tz_offset = self.start_date.utc_offset/60

      if self.public_start_date
        day = self.public_start_date.day
        month = self.public_start_date.month
        self.public_start_date = self.public_start_date.in_time_zone.change({:day => day, :month => month, :hour => 0 , :min => 0 , :sec => 0 })
      else
        self.public_start_date = self.start_date
      end
    end

    if !public_number_of_days || (public_number_of_days == 0)
      self.public_number_of_days = self.number_of_days
    end
  end
  
  # before save check that the public dates etc are within the time period
  def check_public_dates
    raise I18n.t("planner.core.errors.messages.public-dates-not-in-range") if public_start_date < start_date
    if number_of_days > 0
      raise I18n.t("planner.core.errors.messages.public-dates-not-in-range") if public_end_date > end_date
    end
  end

  def end_date
    start_date + (number_of_days - 1).days
  end

  def public_end_date
    public_start_date + (public_number_of_days - 1).days
  end

  def on_now?
    start_date.to_date <= Date.today && end_date >= Date.today
  end

  def on_now_for_public?
    public_start_date.to_date <= Date.today && public_end_date >= Date.today
  end

  def end_dates_the_same?
    end_date == public_end_date
  end

  def start_dates_the_same?
    start_date == public_start_date
  end

  def pub_dates_the_same?
    start_dates_the_same? && end_dates_the_same?
  end

end
