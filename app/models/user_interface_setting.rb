class UserInterfaceSetting < ActiveRecord::Base
  attr_accessible :key, :_value
  
  def value
    return Marshal.load(_value)
  end
end
