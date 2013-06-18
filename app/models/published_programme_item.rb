#
#
#
class PublishedProgrammeItem < ActiveRecord::Base
  acts_as_audited

  has_many  :published_programme_item_assignments, :dependent => :destroy #, :class_name => 'Published::ProgrammeItemAssignment'
  has_many  :people, :through => :published_programme_item_assignments
  
  acts_as_taggable

  belongs_to :format 
  
  has_one :published_room_item_assignment, :dependent => :destroy
  has_one :published_room, :through => :published_room_item_assignment
  has_one :published_time_slot, :through => :published_room_item_assignment, :dependent => :destroy

  # The relates the published programme item back to the original programme item
  has_one :publication, :foreign_key => :published_id, :as => :published
  has_one :original, :through => :publication,
          :source => :original,
          :source_type => 'ProgrammeItem'

  def pub_number
    if pub_reference_number
      return pub_reference_number
    else
      return id.to_s
    end
  end
          
  def timeString
    return published_time_slot.start.strftime('%m%d %H:%M')
  end
  
  def shortDate
    return published_time_slot.start.strftime('%m/%d')
  end

# TODO - change the JSON representation  
    # {"id":"1865",
    # "title":"Sing Along Chicon 2000 Songbook",
    # "precis":"Everyone who comes to the sing-a-long gets to keep the Chicon 2000 filk book.",
    
    # "day":"2012-08-30",
    # "time":"10:30",
    
    # "floor":"Bronze West",
    # "room":"Gold Coast",
    
    # "people":[{"id":"2539","name":"Elliott Mason"},{"id":"2318","name":"Jan DiMasi"}]}
  def as_json(options={})
    res = super(
        :except => [:created_at , :updated_at, :lock_version, :format_id, :end, :comments, :language,
              :acceptance_status_id, :mailing_number, :invitestatus_id, :invitation_category_id,
              :last_name, :first_name, :suffix, :pub_reference_number, :end, :duration, :short_title, :published_venue_id,
              ],
        :methods => [:shortDate, :timeString, :pub_number, :pubFirstName, :pubLastName, :pubSuffix],
        :include => {:published_time_slot => {}, :published_room => {:include => :published_venue}, :people => {}}
        )
        
        res['hhhh'] = 'hhhh'
        
        
    # logger.debug res

    return res
  end
end
