#
#
#
module MailReportsService
  
  @@mapping = {
    "person" => "people.last_name",
    "mailing" => "mailings.mailing_number",
    "content" => "content",
    "status" => "email_status_id",
    "date_sent" => "date_sent",
    "testrun" => "testrun",
    "mailing_id" => "mailing_id",
    "person_id" => "person_id",
  }
  
  @@types = {
    "person" => :string,
    "mailing" => :integer,
    "mailing_id" => :integer,
    "person_id" => :integer,
  }
  
  #
  # Get the histories order by person
  #
  def self.getMailHistory(conditions = {}, options = {} )
    
    per_page = nil
    count = MailHistory.count :joins => [ :person , :mailing ], :conditions => conditions

    if options[:per_page]
      per_page = options[:per_page]
      offset = (options[:page].to_i - 1) * options[:per_page].to_i
    else
      offset = 0
    end
    
    order = nil
    if options[:sort_by]
      order = @@mapping[options[:sort_by]] + " " + options[:order]
    end
    
    clause = ""
    if options[:filters]
      options[:filters].each do |key, val|
        if !val.blank? && @@mapping[key.to_s]
          clause += " AND " if !clause.blank?
          case @@types[key.to_s]
          when :integer
            clause += @@mapping[key.to_s] + " = " + val.to_s 
          else
            clause += @@mapping[key.to_s] + " like '%" + val + "%'" 
          end
        end
      end
    end
    
    conditions = clause
    
    MailHistory.all :joins => [ :person , :mailing ], :conditions => conditions,
        :order => 'people.last_name, people.first_name, mailings.id',
        :offset => offset, :limit => per_page, :order => order
    
  end

  #
  #
  #  
  def self.getNumberOfMailHistories(conditions = {}, options = {})
    clause = nil
    if options[:filters]
      options[:filters].each do |key, val|
        if val && @@mapping[key.to_s]
          clause += " AND " if clause
          clause = @@mapping[key.to_s] + " like '%" + val + "%'" 
        end
      end
    end
    
    conditions = clause
    
    MailHistory.count :joins => [ :person , :mailing ], :conditions => conditions
  end
  
end
