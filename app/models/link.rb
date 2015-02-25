class Link < ActiveRecord::Base
  attr_accessible :lock_version, :linkedto_id, :linkedto_type

  audited

  belongs_to :linkedto, :polymorphic => :true
  
  def linkedto
    linkedto_type.constantize.find(linkedto_id)
  end
  
end
