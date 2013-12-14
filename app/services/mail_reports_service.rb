#
#
#
module MailReportsService
  
  def self.countItems(filters = nil, nameSearch = nil, page_to = nil)
    args = genArgsForSql(nameSearch, filters, page_to)
    
    MailHistory.count args
  end
  
  def self.findItems(rows=15, page=1, index=nil, sort_order='asc', filters = nil, nameSearch = nil)
    args = genArgsForSql(nameSearch, filters)
    
    offset = (page - 1) * rows.to_i
    args.merge!(:offset => offset, :limit => rows)
    
    if (index != nil && index != "")
       args.merge!(:offset => offset, :limit => rows, :order => index + " " + sort_order)
    else
       args.merge!(:offset => offset, :limit => rows, :order => "people.last_name, people.first_name, mailings.id")
    end

    MailHistory.find :all, args
  end
  
  ##########
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
    
    conditions = buildClause options

    MailHistory.all :joins => [ :person , :mailing ], :conditions => conditions,
        :order => 'people.last_name, people.first_name, mailings.id',
        :offset => offset, :limit => per_page, :order => order
  end

  #
  #
  #  
  def self.getNumberOfMailHistories(conditions = {}, options = {})
    conditions = self.buildClause options
    
    MailHistory.count :joins => [ :person , :mailing ], :conditions => conditions
  end
  
  #
  #
  #
  def self.buildClause(options)
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
    return clause
  end
  
protected

  def self.genArgsForSql(nameSearch, filters, page_to = nil)
    clause = DataService.createWhereClause(filters, 
                  ['email_status_id','testrun', 'mailing_id'],
                  ['email_status_id','testrun', 'mailing_id'], ['people.last_name'])
                  
    if nameSearch #&& ! nameSearch.empty?
      # get the last name from the filters and use that in the clause
      st = DataService.getFilterData( filters, 'people.last_name' )
      if (st)
      clause = DataService.addClause(clause,'people.last_name like ? OR pseudonyms.last_name like ? OR people.first_name like ? OR pseudonyms.first_name like ?','%' + st + '%')
      clause << '%' + st + '%'
      clause << '%' + st + '%'
      clause << '%' + st + '%'
      end
    end

    args = { :conditions => clause }
    if nameSearch #&& ! nameSearch.empty?
      args.merge!( :joins => 'JOIN people ON people.id = mail_histories.person_id LEFT JOIN pseudonyms ON pseudonyms.person_id = people.id' )
    else
      args.merge! :joins =>  [ :person, :mailing ]
    end

    args
  end
  
end
