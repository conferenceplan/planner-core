class ImportMapping < ActiveRecord::Base
  attr_accessible :prefix, :first_name, :last_name, :suffix, :line1, :line2, :city, :state, :postcode, :country, :phone, :email,
                  :registration_number, :registration_type, :datasource_dbid, :pub_first_name, :pub_last_name, :pub_suffix, :pub_prefix, :datasource_id,
                  :company, :job_title, :bio, :invite_status, :invite_category, :accept_status

  belongs_to :datasource

end
