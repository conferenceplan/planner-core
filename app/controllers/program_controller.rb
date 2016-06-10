#
#
#
class ProgramController < ApplicationController

  #
  # Set up the cache for the published data. This is so we do not need to hit the DB everytime someone request the published programme grid.
  # For now we only have the cached objects around for 10 minutes. Which means that when the publish has been done within 10 minutes folks
  # will see the new data...
  #
  caches_action :updates,
                :cache_path => Proc.new { |c| c.params.delete_if { |k,v| k.starts_with?('sort')  || k.starts_with?('_dc') || k.starts_with?('undefined')} }
  caches_action :participants,
                :cache_path => Proc.new { |c| c.params.delete_if { |k,v| k.starts_with?('sort')  || k.starts_with?('_dc') || k.starts_with?('undefined')} },
                :unless => Proc.new { |c| !c.params[:callback].blank? }
  # caches_action :index,
                # :cache_path => Proc.new { |c| c.params.delete_if { |k,v| k.starts_with?('sort')  || k.starts_with?('_dc') || k.starts_with?('undefined')} },
                # :unless => Proc.new { |c| !c.params[:callback].blank? }
  
  #
  # Get the full programme
  # If the day is specified then just return the items for that day
  # Can return formatted as an Atom feed or plain HTML
  #
  def getConditions(params)
    day = params[:day] # Day
    name = params[:name]
    lastname = params[:lastname]
    
    conditionStr = "" if day || name || lastname
    conditionStr += '(published_room_item_assignments.day = ?) ' if day
    conditionStr += ' AND ' if day && (name || lastname)
    conditionStr += '(people.last_name like ? OR pseudonyms.last_name like ? OR people.first_name like ? OR pseudonyms.first_name like ? )' if name && !lastname
    conditionStr += '((people.last_name like ? OR pseudonyms.last_name like ?) AND (people.first_name like ? OR pseudonyms.first_name like ?))' if name && lastname
    conditionStr += '(people.last_name like ? OR pseudonyms.last_name like ?)' if lastname && !name
    conditions = [conditionStr] if day || name || lastname
    conditions += [day] if day 
    lastname = name if !lastname
    conditions += ['%'+lastname+'%', '%'+lastname+'%', '%'+name+'%', '%'+name+'%'] if name
    conditions += ['%'+lastname+'%', '%'+lastname+'%'] if lastname && !name
    
    return conditions
  end

  def json_fragment_exist?(key, options = nil)
    return unless cache_configured?
    key = ::ActiveSupport::Cache.expand_cache_key(key, :jbuilder)
    instrument_fragment_cache :exist_fragment?, key do
      cache_store.exist?(key, options)
    end
  end

  def index
    @singleVenue = Venue.count == 1
    
    @extra_item_json = [] if ! @extra_item_json

    if !json_fragment_exist?( [request.host, request.path, params[:scale]] )
      conditions = getConditions(params)
      
      @programmeItems = PublishedProgramItemsService.getPublishedProgramItems
  
      @scale = params[:scale].to_f
      @cloudinaryURI = get_base_image_url
      @partition_val = /upload/
      respond_to do |format|
        format.json
      end
    end

  end
  
  def theme_names
    @theme_names = ThemeName.all
  end
  
  #
  #
  #
  def confirmed_participants
    tag = params[:tag] ? params[:tag] : nil
    @peopleIds = params[:people_ids] ? params[:people_ids].split(',') : nil
    @cloudinaryURI = get_base_image_url
    @partition_val = /upload/
    @showAll = params[:all] ? params[:all] == 'true' : false
    @scale = params[:scale].to_f
    
    @people = PeopleService.findConfirmedPeople(@peopleIds, tag).sort_by{ |a| a.pubLastName.mb_chars.normalize(:kd).gsub(/[^-x00-\x7F]/n, '').downcase.to_s }
  end
  
  #
  # Return a list of rooms - use the same parameters as for the grid
  #
  def rooms
    day = params[:day]
    name = params[:name]
    lastname = params[:lastname]
    
    @rooms = PublishedProgramItemsService.getPublishedRooms day, name, lastname
  end
  
  #
  #
  #
  def participants
    peopleIds = params[:people_ids] ? params[:people_ids].split(',') : nil
    logger.debug peopleIds
    @extra_person_json = [] if ! @extra_person_json
    
    @scale = params[:scale].to_f
    @cloudinaryURI = get_base_image_url
    @partition_val = /upload/
    @participants = PublishedProgramItemsService.findParticipants peopleIds #[2680,2830]
  end  
  
  #
  #
  #
  def publicationDates
    allDates = PublicationDate.all
    @pubDates = []
    
    if allDates
      allDates.each do |v|
        @pubDates << {
          :date => v.created_at,
          :id => v.id,
          :new => v.newitems,
          :updates => v.modifieditems,
          :removed => v.removeditems
        }
      end
    end
  end
  
  #
  # Report back on what has changed. This is used to generate the pink sheets.
  #
  # Item time and room changes
  # New Items
  # Dropped Items
  # Participants Added
  # Participants Dropped
  #
  # Title and Description changes
  #
  # Person add
  # Person roleChange
  # Person remove
  #
  #
  def updates
    @scale = params[:scale].to_f
    @changes = nil

    first_date = PublicationDate.find :first, :order => 'id desc'
    if first_date
      pubIndex = params[:pubidx] ? params[:pubidx].to_i : first_date.id
    else
      pubIndex = 0
    end

    @extra_item_json = [] if ! @extra_item_json
    
    @cloudinaryURI = get_base_image_url
    @partition_val = /upload/

    if pubIndex > 0
      since_date = PublishedProgramItemsService.determineChangeDate(pubIndex)
      @changes = PublishedProgramItemsService.getUpdates(since_date)
    end
  end
  
end
