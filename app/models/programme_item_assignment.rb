class ProgrammeItemAssignment < ActiveRecord::Base  
  attr_accessible :lock_version, :person, :person_id, :role, :role_id, :programme_item_id, :sort_order,
                  :id, :sort_order_position, :role_description

  before_validation :check_role_description

  include RankedModel
  ranks :sort_order, :with_same => [:programme_item_id, :role_id]
  default_scope order('programme_item_assignments.sort_order asc')
  
  belongs_to  :person
  belongs_to  :programmeItem, :foreign_key => "programme_item_id"
  
  audited :associated_with => :person, :allow_mass_assignment => true

  has_enumerated :role, :class_name => 'PersonItemRole'
  
  #
  # TODO - this is a temporary fix until we have a UI for the person to set the description
  #
  def check_role_description
    if role_id == PersonItemRole['Moderator'].id
      role_desc = UserInterfaceSetting.first :conditions => {:key => 'moderator_role'}
      if role_desc
        self.role_description = role_desc._value
      end
    end
  end

end
