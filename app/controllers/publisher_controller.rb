#
#
#
require 'publish_job'

class PublisherController < PlannerController

  def index
    @extra_pub_index_json = [] if !@extra_pub_index_json
    @publicationInfo = PublicationDate.last
  end
  
  # publish the selected program items
  def publish
    @extra_pub_review_json = [] if !@extra_pub_review_json
    ref_numbers = params[:ref_numbers] ? params[:ref_numbers] == 'true' : false
    
    pstatus = PublicationStatus.first
    pstatus = PublicationStatus.new if pstatus == nil
    if pstatus.status != :inprogress
      pstatus.status = :inprogress
      pstatus.save!
      
      pubjob = PublishJob.new(ref_numbers)
      
      # Create a job that will be run seperately
      Delayed::Job.enqueue pubjob
    end

    render status: :ok, text: {}.to_json
  end
  
  def publishPending
    # if we are using sidekiq then we need to check that...
    pstatus = PublicationStatus.first
    
    pending = (pstatus != nil) && (pstatus.status == :inprogress)
    
    render json: {'pending' => pending.to_json}
  end
  
  def review
    pubjob = PublishJob.new(false)
    @candidateNewItems = []
    @candidateNewItems.concat(pubjob.getNewProgramItems()) # all unpublished programme items
    @candidateNewItems.concat(pubjob.getNewChildren())
    @candidateModifiedItems = pubjob.getModifiedProgramItems() # all programme items that have changes made (room assignment, added person, details etc)
    @candidateRemovedItems  = []
    @candidateRemovedItems.concat(pubjob.getRemovedProgramItems()) # all items that should no longer be published
    @candidateRemovedItems.concat(pubjob.getUnpublishedItems()) # all items that should no longer be published
    @candidateRemovedItems.concat(pubjob.getRemovedSubItems())
    
    @candidateRooms = pubjob.getModifiedRooms()
    @candidateVenues = pubjob.getModifiedVenues()
 
    @extra_pub_review_json = [] if ! @extra_pub_review_json
    
    # Get a list of the people that have change since the past pub date
    lastPubDate = PublicationDate.order('id desc').first
    if (lastPubDate)
      @peopleChanged = PublishedProgramItemsService.getUpdatedPeople lastPubDate.timestamp
    end
  end

  def pending_publish_count
    pubjob = PublishJob.new(false)
    @pending_count = 0
    @pending_count += pubjob.getNewProgramItems().count
    @pending_count += pubjob.getNewChildren().count
    @pending_count += pubjob.getModifiedProgramItems().count
    @pending_count += pubjob.getRemovedProgramItems().count
    @pending_count += pubjob.getUnpublishedItems().count
    @pending_count += pubjob.getRemovedSubItems().count
 
    @pending_count += pubjob.getModifiedRooms().count
    @pending_count += pubjob.getModifiedVenues().count
 
    lastPubDate = PublicationDate.order('id desc').first
    if lastPubDate
      # TODO - R4 FIX
      # pending_people = PublishedProgramItemsService.getUpdatedPeople(lastPubDate.timestamp)
      # @pending_count += pending_people[:updatedPeople].size + pending_people[:removedPeople].size
    end
  end

  private

  def check_subscription_status?
    false
  end
end
