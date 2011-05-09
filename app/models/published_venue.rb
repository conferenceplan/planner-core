#
#
#
class PublishedVenue < ActiveRecord::Base
  has_many  :rooms, :class_name => 'Published::Room'

  # The relates the published venue back to the original venu
  has_one :publication, :foreign_key => :published_id
  has_one :original, :through => :publication,
          :source => :original,
          :source_type => 'Venue'
end
