class Venue < ActiveRecord::Base
  attr_accessible :lock_version, :name, :sort_order

  include RankedModel
  ranks :sort_order

  default_scope order('sort_order asc, name asc')
  
  has_many  :rooms, :dependent => :delete_all
  validates_presence_of :name

  audited :allow_mass_assignment => true

  has_one :publication, :foreign_key => :original_id, :as => :original
  has_one :published, :through => :publication,
          :source => :published,
          :source_type => 'PublishedVenue'
end
