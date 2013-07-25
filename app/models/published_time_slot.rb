#
#
#
class PublishedTimeSlot < ActiveRecord::Base
  audited
  
  def as_json(options={})
    
    super(options)
    
    # logger.debug '***************'
    # returning super() do |json_hash|
        # # :except => [:created_at , :updated_at, :lock_version, :format_id, :end, :comments, :language,
              # # :acceptance_status_id, :mailing_number, :invitestatus_id, :invitation_category_id,
              # # :last_name, :first_name, :suffix, :pub_reference_number, :end, :short_title, :published_venue_id,
              # # ],
        # # :methods => [:pub_number, :pubFirstName, :pubLastName, :pubSuffix],
        # # :include => {:published_time_slot => {:as => 'oo'}, :published_room => {:include => :published_venue}, :people => {}}
        # # ) do | json_hash |
          # json_hash["time_slot"] = json_hash["published_time_slot"] #.delete("duration")
#           
        # end
  end
end
