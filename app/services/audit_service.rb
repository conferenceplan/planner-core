#
#
#
module AuditService
  
  #
  #
  #
  def self.getItemChangeHistory(count = 20)
    
    # Audited::Adapters::ActiveRecord::Audit.unscoped.where("auditable_type = ?", 'ProgrammeItem')
    Audited::Adapters::ActiveRecord::Audit.where("auditable_type = ? OR auditable_type = ?", 'ProgrammeItem', 'ProgrammeItemAssignment')
                                          .order("created_at desc").limit(count)
                                          
  end

end
