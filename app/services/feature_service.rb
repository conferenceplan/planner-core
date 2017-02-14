#
#
#
module FeatureService
  
  #
  #
  #
  def self.has?(feature)
    
    Feature.pluck(:name).include? feature
    
  end
  
  #
  # Place holder for feature enablement
  #
  def self.enabled?(feature)
    
    true
    
  end
  
  #
  #
  #
  def self.is_current?
    true
  end

end
