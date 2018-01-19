class TagContext < ActiveRecord::Base
  attr_accessible :lock_version, :name, :publish
  has_many :taggings,
           foreign_key: 'context',
           primary_key: :name,
           class_name: 'ActsAsTaggableOn::Tagging'
  has_many :tags, through: :taggings
end
