module RoomsHelper

  def getFreeTimes(room, day)
    # TODO - change so that it does a query
    free_times = room.free_times
    
    if free_times = nil || free_times.size == 0
      free_times = room.free_times.new(
#        :day => day,
         :start_time => SITE_CONFIG[:conference][:start_date],
         :end_time => SITE_CONFIG[:conference][:start_date]
        )
    end
  end

end
