class People::TagsController < ApplicationController
  
  def index
    # Get all the tags for all the people
    @tags = Person.tag_counts_on(:activities)
    render :layout => 'content'
  end
  
  # All the other methods take the id of the person to update
  
  def add
    @person = Person.find(params[:person_id])
    tag = params[:tag]
    
    # add new tag to the person?
#    @person.tag_list.add(tag)
    @person.activity_list.add(tag)
    @person.save
    
    render :layout => 'content'
  end
  
  def show
    person = Person.find(params[:person_id])
    @tags = person.activity_list
    
    render :layout => 'content'
  end

  def list
    @tags = Person.tag_counts_on(:activities)
    
    respond_to do |format|
      format.xml
    end
  end
  
  def remove
    @person = Person.find(params[:person_id])
    
    # remove tag from the person?
    
    render :layout => 'content'
  end

end
