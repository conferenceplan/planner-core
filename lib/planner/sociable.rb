
require 'active_support/concern'

module Planner
  module Sociable
    extend ActiveSupport::Concern
    
    module ClassMethods
      def has_social_media *args
        # Available options include:
        # :facebook, :twitter/:twitterinfo, :linkedin, :youtube, :twitch, 
        # :instagram, :flickr, :reddit, :othersocialmedia, :website, :url
        # base.instance_variable_set :@social_base_urls, {

        @@social_base_urls = {
          :facebook => "http://www.facebook.com/",
          :twitter => "http://www.twitter.com/",
          :linkedin => "http://www.linkedin.com/in/",
          :youtube => "http://www.youtube.com/user/", 
          :twitch => "http://www.twitch.tv/", 
          :instagram => "http://www.instagram.com/", 
          :flickr => "http://www.flickr.com/photos/", 
          :reddit => "http://www.reddit.com/user/"
        }

        ## Set accessible attributes
        attr_accessible *args

        ## Handle twitter attr variation and define its method
        if args.include?(:twitter) || args.include?(:twitterinfo)
          send(:define_method, :twitter) do
            if self.has_attribute?(:twitter)
              self.read_attribute(:twitter)
            elsif self.has_attribute?(:twitterinfo)
              self.read_attribute(:twitterinfo)
            else
              nil
            end
          end
        end
        
        ## Define ID methods for social media handles
        if args.include?(:facebook)
          send(:define_method, :facebookid) do
            /[^\/|^@]+$/.match(facebook.present? ? facebook.gsub(/\/+$/,'') : '').to_s
          end
        end

        if args.include?(:twitter) || args.include?(:twitterinfo)
          send(:define_method, :twitterid) do
            /[^\/|^@]+$/.match(twitter.present? ? twitter.gsub(/\/+$/,'') : '').to_s
          end
        end
        
        if args.include?(:linkedin)
          send(:define_method, :linkedinid) do
            /[^\/|^@]+$/.match(linkedin.present? ? linkedin.gsub(/\/+$/,'') : '').to_s
          end
        end

        if args.include?(:youtube)
          send(:define_method, :youtubeid) do
            /[^\/|^@]+$/.match(youtube.present? ? youtube.gsub(/\/+$/,'') : '').to_s
          end
        end

        if args.include?(:twitch)
          send(:define_method, :twitchid) do
            /[^\/|^@]+$/.match(twitch.present? ? twitch.gsub(/\/+$/,'') : '').to_s
          end
        end

        if args.include?(:instagram)
          send(:define_method, :instagramid) do
            /[^\/|^@]+$/.match(instagram.present? ? instagram.gsub(/\/+$/,'') : '').to_s
          end
        end

        if args.include?(:flickr)
          send(:define_method, :flickrid) do
            /[^\/|^@]+$/.match(flickr.present? ? flickr.gsub(/\/+$/,'') : '').to_s
          end
        end

        if args.include?(:reddit)
          send(:define_method, :redditid) do
            /[^\/|^@]+$/.match(reddit.present? ? reddit.gsub(/\/+$/,'') : '').to_s
          end
        end

        ## Define fix_url method
        send(:define_method, :fix_url) do |url|
          if url.present?
            res = url.strip # remove trailing and preceding whitespace
            # Add the protocol if not alreay present
            if res.present?
              unless res[/\Ahttp:\/\//] || res[/\Ahttps:\/\//]
                res = "http://#{res}"
              end
            end
            res
          else
            nil
          end
        end

        ## For each social media provider set for the model, define url generator methods
        args.each do |arg|
          if arg == :url || arg == :website
            send(:define_method, :website_url) do
              if self.has_attribute?(:website)
                fix_url(self.read_attribute(:website))
              elsif self.has_attribute?(:url)
                fix_url(self.read_attribute(:url))
              else
                nil
              end
            end
          else
            if arg == :twitter || arg == :twitterinfo
              arg_name = 'twitter'
            else
              arg_name = arg.to_s
            end
            method_name = arg_name + '_url'

            ## Define url method for provider
            send(:define_method, method_name) do
              url = ""
              social_arg = arg_name.to_sym
              if self.respond_to?(social_arg)
                social = self.send(social_arg)
                if social.present?
                  if social[/\Ahttp:\/\//] || social[/\Ahttps:\/\//]
                    ## If social attribute is already a url, use it directly
                    url = social
                  else
                    ## If social attribute is not a url, build the url using one of the base urls defined in "social_base_urls" variable
                    base = @@social_base_urls[social_arg]
                    if base.present?
                      social_id = self.send(social_arg.to_s + "id")
                      url = base + social_id
                    end
                  end
                end
              end

              url.gsub(/\/+$/,'')
            end

          end
        end
        
        ## Define social media checker
        send(:define_method, :has_social_media?) do
          (self.respond_to?(:facebook_url) && facebook_url.present?) || 
          (self.respond_to?(:twitter_url) && twitter_url.present?) || 
          (self.respond_to?(:linkedin_url) && linkedin_url.present?) || 
          (self.respond_to?(:youtube_url) && youtube_url.present?) || 
          (self.respond_to?(:twitch_url) && twitch_url.present?) || 
          (self.respond_to?(:instagram_url) && instagram_url.present?) || 
          (self.respond_to?(:flickr_url) && flickr_url.present?) || 
          (self.respond_to?(:reddit_url) && reddit_url.present?) || 
          (self.respond_to?(:othersocialmedia_url) && othersocialmedia_url.present?) || 
          (self.respond_to?(:website_url) && website_url.present?)
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Planner::Sociable)
