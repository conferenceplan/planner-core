class Translation < ActiveRecord::Base
  attr_accessible :locale, :key, :value, :interpolations, :is_proc
end
