#
# TODO - refactor to generic tag cont
#
class People::TagsController < ApplicationController
  before_filter :require_user

  #
  # Show the tags for every context for the given person
  #
  def show
    # For each of the possible contexts get the tags...
    person = Person.find(params[:person_id])
    
    # 1. Get the set of contexts
    contexts = TagContext.all
    # 2. For each context get the tags for thie person and add them to the results
    @allTags = Hash.new
    contexts.each do |context|
      tags = person.tag_list_on( context.name )
      if tags != nil
        @allTags[context.name] = tags
      end
    end
    
    # 3. Then pass this along to the view
    render :layout => 'content'
  end

  #
  # Return all the tags in each context for each person
  #
  def index
    # 1. Get the set of contexts
    contexts = TagContext.all
    # 2. For each context get the tags for thie person and add them to the results
    @allTagCounts = Hash.new
    contexts.each do |context|
      tagCounts = Person.tag_counts_on( context.name )
      if tagCounts != nil
        @allTagCounts[context.name] = tagCounts
      end
    end
    
    # 3. Then pass this along to the view
    respond_to do |format|
      format.html { render :layout => 'content' }# index.html.erb
      format.xml  { render :xml => @allTagCounts } # index.xml.erb
    end
  end
  
  # All the other methods take the id of the person to update
  
  def add
    person = Person.find(params[:person_id])
    tag = params[:tag]
    
    # add new tag to the person?
    person.tag_list.add(tag)
#    person.activity_list.add(tag)
    person.save
    
    render :layout => 'content'
  end
  
#  def list
#    @tags = Person.tag_counts_on(:media)
#    
#    respond_to do |format|
#      format.xml
#    end
#  end
  
  def remove
#    person = Person.find(params[:person_id])
    
    # remove tag from the person?
    
    render :layout => 'content'
  end

end
