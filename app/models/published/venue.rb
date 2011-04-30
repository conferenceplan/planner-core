#
#
#
class Published::Venue < ActiveRecord::Base
  has_many  :rooms, :class_name => 'Published::Room'

  # The relates the published venue back to the original venu
  has_one :publication, :class_name => 'Published::Publication'
  has_one :original, :through => :publication, #, :class_name => 'Published::Publication',
          :source => :original,
          :source_type => 'Venue'
end
