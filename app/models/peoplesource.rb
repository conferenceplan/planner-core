class Peoplesource < ActiveRecord::Base
  attr_accessible :person, :person_id, :datasource, :datasource_id, :datasource_dbid
  belongs_to :person
  belongs_to :datasource
end
