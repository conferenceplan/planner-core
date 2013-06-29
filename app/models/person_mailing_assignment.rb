class PersonMailingAssignment < ActiveRecord::Base
  belongs_to  :person
  belongs_to  :mailing
  
  has_many  :mail_histories

  # def as_json(options={})
#     
    # # if options[:include_pseudonym]
      # # res = super( :include => [{:person => :pseudonym}, :mailing] )
    # # else
    # # super(:include => [:person, :mailing])
    # # end
# 
    # # return res
#     
    # super()
#     
  # end
end
