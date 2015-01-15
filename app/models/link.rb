class Link < ActiveRecord::Base
  attr_accessible :lock_version, :linkedto_id, :linkedto_type, :linkedfrom_id, :linkedfrom_type

  belongs_to :linkedto, :polymorphic => :true
  # belongs_to :linkedfrom, :polymorphic => :true
  
  def linkedto
    linkedto_type.constantize.find(linkedto_id)
  end

  def linkedfrom
    linkedfrom_type.constantize.find(linkedfrom_id)
  end
  
end