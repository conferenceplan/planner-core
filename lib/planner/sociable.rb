
require 'active_support/concern'

module Planner
  module Sociable
    extend ActiveSupport::Concern

    module ClassMethods
      def has_social_media *args
        # Available options include:
        # :facebook, :twitter/:twitterinfo, :linkedin, :youtube, :twitch, 
        # :instagram, :flickr, :reddit, :othersocialmedia, :website, :url

        attr_accessible *args

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

        if args.include?(:website) || args.include?(:url)
          send(:define_method, :website_url) do
            if self.has_attribute?(:website)
              fix_url(self.read_attribute(:website))
            elsif self.has_attribute?(:url)
              fix_url(self.read_attribute(:url))
            else
              nil
            end
          end
        end


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
