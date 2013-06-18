class PersonMailingAssignment < ActiveRecord::Base
  belongs_to  :person
  belongs_to  :mailing
  
  has_many  :mail_histories

  def as_json(options={})
    res = super(:include => [:person, :mailing])

    return res
  end
end
