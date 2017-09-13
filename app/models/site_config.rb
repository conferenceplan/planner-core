class SiteConfig < ActiveRecord::Base
  attr_accessible :lock_version, :name, :time_zone, :print_time_format,
                  :start_date, :public_start_date, :end_date, :public_end_date

  after_validation :adjust_timezone

  def adjust_timezone
    if self.public_start_date.time_zone.name.downcase != self.time_zone.downcase
      Time.use_zone(self.time_zone) do 
        if self.public_start_date.present?
          self.public_start_date = (self.public_start_date.in_time_zone - self.tz_offset_seconds)
        end
        if self.public_end_date.present?
          self.public_end_date = (self.public_end_date.in_time_zone - self.tz_offset_seconds)
        end

        if self.read_start_date.present?
          self.start_date = (self.start_date.in_time_zone - self.tz_offset_seconds)
        end
        if self.read_end_date.present?
          self.end_date = (self.end_date.in_time_zone - self.tz_offset_seconds)
        end
      end
    end
  end

  def tz_offset
    tz_offset_seconds / 60 if tz_offset_seconds.present?
  end

  def tz_offset_seconds
    if self.public_start_date.present?
      offset = self.public_start_date.in_time_zone(self.time_zone).utc_offset
    else
      offset = 0
    end
    offset
  end

  def start_date
    _start_date = read_start_date
    if _start_date.blank? && public_start_date.present?
      _start_date = public_start_date
    end

    _start_date
  end

  def end_date
    _end_date = read_end_date
    if _end_date.blank? && public_end_date.present?
      _end_date = public_end_date
    end

    _end_date
  end

  def read_start_date
    self[:start_date]
  end

  def read_end_date
    self[:end_date]
  end
  
  # before save check that the public dates etc are within the time period
  # def check_public_dates
  #   raise I18n.t("planner.core.errors.messages.public-dates-not-in-range") if public_start_date < start_date
  #   if number_of_days > 0
  #     raise I18n.t("planner.core.errors.messages.public-dates-not-in-range") if public_end_date > end_date
  #   end
  # end

  def number_of_days
    if end_date.present?
      _number_of_days = (end_date.to_date - start_date.to_date).to_i + 1
    end

    _number_of_days
  end

  def public_number_of_days
    if public_end_date.present?
      _public_number_of_days = (public_end_date.to_date - public_start_date.to_date).to_i + 1
    end

    _public_number_of_days
  end

  def on_now?
    Time.use_zone(self.time_zone) do 
      start_date.in_time_zone <= Time.current && end_date.in_time_zone >= Time.current
    end
  end

  def on_now_for_public?
    Time.use_zone(self.time_zone) do 
      public_start_date.in_time_zone <= Time.current && public_end_date.in_time_zone >= Time.current
    end
  end

  def has_finished?
    Time.use_zone(self.time_zone) do 
      end_date.in_time_zone > Time.current
    end
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

  def single_day_event?
    (end_date.to_date - start_date.to_date).to_i == 0
  end

  def all_day_event?
    Time.use_zone(self.time_zone) do 
      (public_start_date.in_time_zone.beginning_of_day - public_start_date.in_time_zone).to_i <= 60 && 
      (public_end_date.in_time_zone.end_of_day - public_end_date.in_time_zone).to_i <= 60
    end
  end

end
