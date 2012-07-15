class Peoplesource < ActiveRecord::Base
  belongs_to :person
  belongs_to :datasource
end
