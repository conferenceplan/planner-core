module Planner
  module Controllers
    module ResourceMethods

        def find_page
          begin
            @page = 0
            idx = params[:idx]
            limit = params[:limit] ? params[:limit].to_i : nil
            _find_page(idx, limit)
            render json: @page.to_json, :content_type => 'application/json' if !lookup_context.exists? :find_page, params[:controller]
          rescue => ex
            render status: :bad_request, text: ex.message
          end
        end

        def index
          begin
            render json: @collection.to_json, :content_type => 'application/json' if !lookup_context.exists? :index, params[:controller]
          rescue => ex
            render status: :bad_request, text: ex.message
          end
        end
        
        def create
          begin
            before_save
            @object.save!
            _after_save
            after_save
            render json: @object.to_json, :content_type => 'application/json' if !lookup_context.exists? :create, params[:controller]
          rescue => ex
            render status: :bad_request, text: ex.message
          end
        end
        
        def show
          render json: @object.to_json, :content_type => 'application/json' if !lookup_context.exists? :show, params[:controller]
        end
          
        def update
          begin
            before_update
            @object.update_attributes params[object_name]
            _after_update
            after_update
            render json: @object.to_json, :content_type => 'application/json' if !lookup_context.exists? :update, params[:controller]
          rescue => ex
            render status: :bad_request, text: ex.message
          end
        end
        
        def destroy
          begin
            @object.destroy
            render status: :ok, text: {}.to_json
          rescue => ex
            render status: :bad_request, text: ex.message
          end
        end
      
        protected
          def _find_page(idx, limit)
            @page = 0
          end
        
          def before_update
          end

          def before_save
          end

          def after_update
          end

          def after_save
          end

          def _after_update
            if @object.respond_to? :update_themes
              theme_names = params[:theme_name_ids].split(",") # comma seperated list, split into ids
              @object.update_themes theme_names
            end
            if @object.respond_to? :update_categories
              category_names = params[:category_name_ids].split(",") # comma seperated list, split into ids
              @object.update_categories category_names
            end
          end
        
          def _after_save
            if @object.respond_to? :update_themes
              theme_names = params[:theme_name_ids].split(",") # comma seperated list, split into ids
              @object.update_themes theme_names
            end
            if @object.respond_to? :update_categories
              category_names = params[:category_name_ids].split(",") # comma seperated list, split into ids
              @object.update_categories category_names
            end
          end

        
          def action
            params[:action].to_sym
          end
      
          def collection
            _collection
          end
          
          def _collection
            model_class.scoped
          end
          
          def model_name
             "#{controller_name.classify}".downcase.singularize
          end
      
          def model_class
            self.class.name.sub('Controller', '').singularize.constantize
            # "#{controller_name.classify}".constantize
          end
      
          def object_name
            controller_name.singularize
          end
      
          def load_resource
            if member_action?
              @object ||= load_resource_instance
      
              instance_variable_set("@#{object_name}", @object)
            else
              @collection ||= collection
      
              instance_variable_set("@#{controller_name}", @collection)
            end
          end
      
          def load_resource_instance
            if new_actions.include?(action)
              build_resource
            elsif params[:id]
              find_resource
            end
          end
          
          def find_resource
            model_class.find(params[:id])
          end
        
          def build_resource
            model_class.new params[object_name] #"#{model_name}"]
          end
          
          def collection_actions
            [:index]
          end
      
          def member_action?
            !collection_actions.include? action
          end
      
          def new_actions
            [:new, :create]
          end
        
    end
  end
end