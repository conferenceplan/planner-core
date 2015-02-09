#
#
#
class LinkedResourceController < ResourceController

  def collection
    linkedto_type = params[:linkedto_type] ? params[:linkedto_type] : nil
    linkedto_id = params[:linkedto_id] ? params[:linkedto_id].to_i : nil
    
    if linkedto_type
      super.joins(:links).where({'links.linkedto_type' => linkedto_type, 'links.linkedto_id' => linkedto_id})
    else
      super  
    end
  end

  def create
    begin
      Link.transaction do
        @object.save!
        if @linkedto_id
          link = @object.links.new
          link.linkedto_id = @linkedto_id
          link.linkedto_type = @linkedto_type
          link.save!
        end
        render json: @object.to_json, :content_type => 'application/json' if !lookup_context.exists? :create, params[:controller]
      end
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end

  protected
    def build_resource
      @linkedto_id = params[:linkedto_id] ? params[:linkedto_id].to_i : nil
      params[object_name].delete('linkedto_id') if params[object_name]
      @linkedto_type = params[:linkedto_type] ? params[:linkedto_type] : ''
      params[object_name].delete('linkedto_type') if params[object_name]
      if params[object_name]
        model_class.new params[object_name] #"#{model_name}"]
      else
        p = params.clone
        p.delete('linkedto_id')
        p.delete('linkedto_type')
        p.delete('tenant')
        p.delete('locale')
        p.delete('format')
        p.delete('controller')
        p.delete('action')
        model_class.new p
      end
    end


end