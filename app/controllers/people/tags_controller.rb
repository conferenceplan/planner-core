class People::TagsController < ApplicationController
  
  def index
    # Get all the tags for all the people
    @tags = Person.tag_counts
    render :layout => 'content'
  end
  
  # All the other methods take the id of the person to update
  
  def add
    person = Person.find(params[:person_id])
    
    # add new tag to the person?
    
    render :layout => 'content'
  end
  
  def show
    @tags = Person.find(params[:person_id]).tag_list
    
    render :layout => 'content'
  end

  def list
    @tags = Person.find(params[:person_id]).tag_list
    
    render :layout => 'content'
  end
  
  def remove
    person = Person.find(params[:person_id])
    
    # remove tag fromthe person?
    
    render :layout => 'content'
  end

end
