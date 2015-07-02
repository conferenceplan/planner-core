class Category < ActiveRecord::Base
  attr_accessible :lock_version, :categorized_id, :categorized_type, :category_name

  belongs_to :category_name
  belongs_to :categorized, :polymorphic => :true

end
