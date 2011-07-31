#
#
#
class PublisherController < PlannerController
  include TagUtils
  
  def index
    @publicationInfo = PublicationDate.last
  end
  
  # publish the selected program items
  def publish
    # Create a job that will be run seperately
    pubjob = PublishJob.new
    if ENV['SENDGRID_DOMAIN'] == 'heroku.com'
      pubjob.perform
      @publicationInfo = PublicationDate.last
    else
      Delayed::Job.enqueue pubjob #PublishJob.publish()
    end
        
    render :layout => 'content'
  end
  
  def review
    pubjob = PublishJob.new
    @candidateNewItems = pubjob.getNewProgramItems() # copy all unpublished programme items
    @candidateModifiedItems = pubjob.getModifiedProgramItems() # copy all programme items that have changes made (room assignment, added person, details etc)
    @candidateRemovedItems = []
    @candidateRemovedItems.concat(pubjob.getRemovedProgramItems()) # remove all items that should no longer be published
    @candidateRemovedItems.concat(pubjob.getUnpublishedItems()) # remove all items that should no longer be published
  end
  
  # list all the published programme items
  def list
  end
  
end
