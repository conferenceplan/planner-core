class ProgramController < ApplicationController
  
  # Provide the program as a grid
  def index
    @assignments = PublishedRoomItemAssignment.all(:joins => [:published_room, :published_time_slot, :published_programme_item], :order => 'published_time_slots.start ASC, published_rooms.name ASC')
    
    respond_to do |format|
      format.html { render :layout => 'content' }
      format.atom # for an Atom feed (for readers)
    end
  end

  def list
  end

  def stream
  end

  def feed
  end

end
