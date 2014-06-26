#
#Upload a file into a temp area and keep the name and path in the session
#
class FileUploadsController < ApplicationController
  
  def create
    # filename
    # content type
    data = params[:files]
    file_name = ''
    
    data.each do |file|
      file_name = file.original_filename
      
      path = File.join('/tmp/', file_name )
      File.open(path, "wb") { |f| f.write(file.read) }
    end
    
    
    render json: { "files" => [{
        "name" => file_name #,
        # "size" => 902604,
        # "url" => "http:\/\/example.org\/files\/picture1.jpg",
        # "thumbnailUrl" => "http:\/\/example.org\/files\/thumbnail\/picture1.jpg",
        # "deleteUrl" => "http:\/\/example.org\/files\/picture1.jpg",
        # "deleteType" => "DELETE"
      }]}.to_json, :content_type => 'application/json'
  end

  # TODO - not needed ???
  # def index
  # end
# 
  # def show
  # end
# 
  # def update
  # end
#   
  # def destroy
    # # remove the file from the system
    # render status: :ok, text: {}.to_json
  # end

end
