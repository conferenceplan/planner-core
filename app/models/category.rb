class Category < ActiveRecord::Base
  attr_accessible :lock_version, :categorized_id, :categorized_type, :category_name, :category_name_id

  belongs_to :category_name
  belongs_to :categorized, polymorphic: true

  validates :category_name, presence: true
  validates :categorized_type, presence: true
  validates :categorized_id,
            presence: true,
            numericality: { only_integer: true }
  validates :categorized, presence: { message: 'record doesn\'t exist!' }
end
