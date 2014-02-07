class Format < ActiveRecord::Base

  has_many  :programme_items

  has_many  :external_images, :as => :imageable,  :dependent => :delete_all do
    def use(u) # get the image for a given use (defined as a string)
      find(:all, :conditions => ['external_images.use = ?', u])
    end
  end
  
end

