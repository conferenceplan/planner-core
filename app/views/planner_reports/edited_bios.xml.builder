xml.people do
  @editedBios.each do |e|
    xml.person do
      name = e.person.getFullPublicationName
      xml.name(name)    
      xml.bio do
           xml.cdata! e.bio
      end
      
      if (e.website)
            xml.WebSite :type => 'url',
              :href => e.website
      end
      if (e.twitterinfo)
            xml.TwitterInfo(e.twitterinfo)
      end
      if (e.othersocialmedia)
            xml.OtherSocialMediaInfo :type => 'url',
              :href => e.othersocialmedia
      end
      if e.person.bio_image && e.person.bio_image.bio_picture.url
         xml.PhotoUrl :type => 'url',
           :href => get_base_image_url + e.person.bio_image.bio_picture.url.partition(/upload/)[2]
      else
          if (e.photourl)
             xml.PhotoUrl :type => 'url',
               :href => e.photourl
          end
      end


      if (e.facebook)
            xml.Facebook(e.facebook)
      end
    end
  end
end
