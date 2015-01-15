#
#
#
class LinkedResourceController < ResourceController

  def create
    begin
      @object.save!
      if @linkedto_id
        link = @object.links.new
        link.linkedto_id = @linkedto_id
        link.linkedto_type = @linkedto_type
        link.save!
      end
      render json: @object.to_json, :content_type => 'application/json' if !lookup_context.exists? :create, params[:controller]
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end

  protected
    def build_resource
      @linkedto_id = params[object_name].delete('linkedto_id')
      @linkedto_type = params[object_name].delete('linkedto_type')
      model_class.new params[object_name] #"#{model_name}"]
    end


end