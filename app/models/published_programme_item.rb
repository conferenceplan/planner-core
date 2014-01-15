#
#
#
class PublishedProgrammeItem < ActiveRecord::Base
  audited :allow_mass_assignment => true

  has_many  :published_programme_item_assignments, :dependent => :destroy #, :class_name => 'Published::ProgrammeItemAssignment'
  has_many  :people, :through => :published_programme_item_assignments
  
  acts_as_taggable

  belongs_to :format 
  
  has_one :published_room_item_assignment, :dependent => :destroy
  has_one :published_room, :through => :published_room_item_assignment
  has_one :published_time_slot, :through => :published_room_item_assignment, :dependent => :destroy

  # The relates the published programme item back to the original programme item
  has_one :publication, :foreign_key => :published_id, :as => :published, :dependent => :destroy
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

  def as_json(options={}) 
    
    if options[:new_format] == true
      # New JSON representation  
      # {"id":"1865",
      # "title":"Sing Along Chicon 2000 Songbook",
      # "precis":"Everyone who comes to the sing-a-long gets to keep the Chicon 2000 filk book.",
      res = super(
        :except => [:created_at , :updated_at, :lock_version, :format_id, :end, :comments, :language,
              :acceptance_status_id, :mailing_number, :invitestatus_id, :invitation_category_id,
              :last_name, :first_name, :suffix, :pub_reference_number, :end, :short_title, :published_venue_id,
              ]
        )
      # map duration to mins
      # map precis to desc
      
      res.tap { |hash|
        # hash[:mins] =  hash.delete 'duration'
        hash["id"] =  hash['id'].to_s
        hash[:mins] =  (hash.delete 'duration').to_s
        hash[:desc] =  hash.delete 'precis'
      }
       
      res[:day] = published_time_slot.start.strftime('%A') # currentTime.strftime('%A %H:%M')
      res[:date] = published_time_slot.start.strftime('%Y-%m-%d') # currentTime.strftime('%A %H:%M')
      res[:time] = published_time_slot.start.strftime('%H:%M')
      res[:datetime] = published_time_slot.start
    
      # "loc": [ "Some Room", "Some Area" ],
      res[:loc] = [ published_room.name, published_room.published_venue.name ]

      # "people":[{"id":"2539","name":"Elliott Mason"},{"id":"2318","name":"Jan DiMasi"}]}
      res[:people] = people.collect{ |p|
        { 
          # :id => p.id , 
          :id => p.id.to_s , 
          :name => p.getFullPublicationName.strip
        }
      }
      
      # Tags for the Primary Area
      tracks = tag_list_on('PrimaryArea')
      if tracks && !tracks.empty?
        # res[:track] = tag_list_on('PrimaryArea')
        res[:tags] = tag_list_on('PrimaryArea')
      end
      
        
    else  

      res = super(
        :except => [:created_at , :updated_at, :lock_version, :format_id, :end, :comments, :language,
              :acceptance_status_id, :mailing_number, :invitestatus_id, :invitation_category_id,
              :last_name, :first_name, :suffix, :pub_reference_number, :end, :short_title, :published_venue_id,
              ],
        :methods => [:pub_number]
        )
     
      res['people'] = people.collect{ |p|
        p.as_json({:except => [:created_at , :updated_at, :lock_version, :format_id, :end, :comments, :language,
              :acceptance_status_id, :mailing_number, :invitestatus_id, :invitation_category_id,
              :first_name, :last_name, :suffix, :pub_reference_number, :end, :short_title, :published_venue_id,
              ],
            :methods => [:pubFirstName, :pubLastName, :pubSuffix]}).tap { |hash| 
              hash[:first_name] = hash.delete :pubFirstName
              hash[:last_name] = hash.delete :pubLastName
              hash[:suffix] = hash.delete :pubSuffix
            }
      }
     
      res['time'] = published_time_slot.start
      res['room'] = published_room.as_json({:except => [:created_at , :updated_at, :lock_version, :format_id, :end, :comments, :language,
              :acceptance_status_id, :mailing_number, :invitestatus_id, :invitation_category_id,
              :last_name, :first_name, :suffix, :pub_reference_number, :end, :short_title, :published_venue_id,
              ]})
              
      res['room']['venue'] = published_room.published_venue.as_json({:except => [:created_at , :updated_at, :lock_version, :format_id, :end, :comments, :language,
              :acceptance_status_id, :mailing_number, :invitestatus_id, :invitation_category_id,
              :last_name, :first_name, :suffix, :pub_reference_number, :end, :short_title, :published_venue_id,
              ]})
    end
    
    return res
  end
end
