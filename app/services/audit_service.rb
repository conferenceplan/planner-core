#
#
#
module AuditService
  
  #
  #
  #
  def self.getItemChangeHistory(count = 20)
    
    Audited::Adapters::ActiveRecord::Audit.unscoped.where("(auditable_type = ? OR auditable_type = ?) and user_id is not null", 'ProgrammeItem', 'ProgrammeItemAssignment').
                                          where(self.constraints()).
                                          order("created_at desc, version desc").limit(count)
                                          
  end

  def self.constraints(*args)
    true
  end

end
