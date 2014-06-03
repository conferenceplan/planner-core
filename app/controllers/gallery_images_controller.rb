class GalleryImagesController < PlannerController

  skip_before_filter :verify_authenticity_token # TEMP, TODO - we need to get CKeditor to pass the CSRF params
  
  def index
    @CKEditorFuncNum = params[:CKEditorFuncNum]
    @type = params[:type]
    
    @images = eval(@type).where(:gallery => params[:gallery])
    
    render :layout => 'plain'
  end
  
  def create
    @CKEditorFuncNum = params[:CKEditorFuncNum]
    @error = ''
    @url = ''
    @type = params[:type]
    
    begin
      image = eval(@type).new(:picture => params[:upload], :gallery => params[:gallery])
      image.global = true
      image.filename = params[:upload].original_filename
      image.save!
      
      @url = image.picture.thumbnail.url
    rescue => ex
      @error = ex.message
    end
    render :layout => 'plain'
  end
  
  def show
    candidate = ContentImage.find params[:id]
  end
  
  def destroy
    begin
      candidate = ContentImage.find params[:id]
      candidate.destroy
      render status: :ok, text: {}.to_json
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end
  
  # do we need an update?
  
end
