
require 'active_support/concern'

module Planner
  module Sociable
    extend ActiveSupport::Concern

    module ClassMethods
      def has_social_media *args
        
        attr_accessible *args

        if args.include?(:twitter) || args.include?(:twitterinfo)
          send(:define_method, :twitter) do
            if self.has_attribute?(:twitter)
              twitter
            elsif self.has_attribute?(:twitterinfo)
              twitterinfo
            else
              nil
            end
          end
        end
        
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

        send(:define_method, :has_social_media?) do
          (self.respond_to?(:facebook) && facebook.present?) || 
          (self.respond_to?(:twitter) && twitter.present?) || 
          (self.respond_to?(:linkedin) && linkedin.present?) || 
          (self.respond_to?(:youtube) && youtube.present?) || 
          (self.respond_to?(:twitch) && twitch.present?) || 
          (self.respond_to?(:instagram) && instagram.present?) || 
          (self.respond_to?(:flickr) && flickr.present?) || 
          (self.respond_to?(:reddit) && reddit.present?) || 
          (self.respond_to?(:othersocialmedia) && othersocialmedia.present?)
        end
        
      end
     
    end
  end
end

ActiveRecord::Base.send(:include, Planner::Sociable)
