#
#
#
class PlannerController < ApplicationController
  before_filter :load_site_config, :load_cloudinary_config, :require_user # All controllers that inherit from this will require an authenticated user
  filter_access_to :all # All controllers that inherit from this will be controlled by the access rules
  around_filter :application_time_zone # make sure that we use the timezone as specified in the database

  def application_time_zone(&block)
    Time.use_zone(SITE_CONFIG[:conference][:time_zone], &block)
  end
  
  def load_site_config
    cfg = SiteConfig.find :first # for now we only have one convention... change when we have many (TODO)
    if (cfg) # TODO - temp, to be replaced in other code
      SITE_CONFIG[:conference][:name] = cfg.name
      SITE_CONFIG[:conference][:number_of_days] = cfg.number_of_days
      SITE_CONFIG[:conference][:start_date] = cfg.start_date
      SITE_CONFIG[:conference][:time_zone] = cfg.time_zone
    end
  end
  
  def load_cloudinary_config
    cfg = CloudinaryConfig.find :first # for now we only have one convention... change when we have many (TODO)
    Cloudinary.config do |config|
      config.cloud_name           = cfg ? cfg.cloud_name : ''
      config.api_key              = cfg ? cfg.api_key : ''
      config.api_secret           = cfg ? cfg.api_secret : ''
      config.enhance_image_tag    = cfg ? cfg.enhance_image_tag : false
      config.static_image_support = cfg ? cfg.static_image_support : false
     config.cdn_subdomain = true
    end
  end

  rescue_from ActiveRecord::StaleObjectError do |exception|
    respond_to do |format|
      format.html {
#        correct_stale_record_version
        stale_record_recovery_action
      }
      format.xml  { head :conflict }
      format.json { head :conflict }
    end
  end      

  def permission_denied
    render '/errors/permission_error'
  end

protected

  def stale_record_recovery_action
    flash.now[:error] = "Another user has made a change to that record "+
         "since you accessed the edit form."
# error_messages_for
    render :edit, :status => :conflict, :layout => 'content'
  end

private

  def createWhereClause(filters, integerFieldsSkipIfEmpty = [], integerFields = [])
    clause = nil
    fields = Array::new
    j = ActiveSupport::JSON
    
    if (filters)
      queryParams = j.decode(filters)
      if (queryParams && queryParams["rules"].any?)
        clausestr = ""
        queryParams["rules"].each do |subclause|
          # these are the select type filters - position 0 is the empty position and means it is not selected,
          # so we are not filtering on that item
          next if (integerFieldsSkipIfEmpty.include?(subclause['field']) && subclause['data'] == '0')        
          
          if clausestr.length > 0 
            clausestr << ' ' + queryParams["groupOp"] + ' '
          end
          
          # integer items (integers or select id's) need to be handled differently in the query
          isInteger = integerFields.include?(subclause['field'])
          if subclause["op"] == 'ne' || subclause["op"] == 'nc' || subclause["op"] == 'bn'
            clausestr << subclause['field'] + lambda { return isInteger ? ' != ?' : ' not like ?' }.call
          elsif subclause["op"] == 'ge'
            clausestr << subclause['field'] + lambda { return isInteger ? ' = ?' : ' >= ?' }.call
          elsif subclause["op"] == 'le'
            clausestr << subclause['field'] + lambda { return isInteger ? ' = ?' : ' <= ?' }.call
          elsif subclause["op"] == 'gt'
            clausestr << subclause['field'] + lambda { return isInteger ? ' = ?' : ' > ?' }.call
          elsif subclause["op"] == 'lt'
            clausestr << subclause['field'] + lambda { return isInteger ? ' = ?' : ' < ?' }.call
          else # also the eq, cn, bw
            clausestr << subclause['field'] + lambda { return isInteger ? ' = ?' : ' like ?' }.call
          end
           
          if subclause["op"] == 'nc' || subclause["op"] == 'cn'
             fields << lambda { return isInteger ? subclause['data'].to_i : '%' + subclause['data'] + '%' }.call
          else
             fields << lambda { return isInteger ? subclause['data'].to_i : subclause['data'] + '%' }.call
          end
        end
        clause = [clausestr] | fields
      end
    end
    return clause
  end
  
  def addClause(clause, clausestr, field)
    if clause == nil || clause.empty?
      clause = [clausestr, field]
    else
      isEmpty = clause[0].strip().empty?
      clause[0] = " ( " + clause[0]
      clause[0] += ") AND ( " if ! isEmpty
      clause[0] += " " + clausestr
      clause[0] += " ) "  if ! isEmpty
      if field
        clause << field
      end
    end
    
    return clause
  end
end
