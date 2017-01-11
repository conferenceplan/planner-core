#
#
#
module MailReportsService
  
  def self.countItems(filters = nil, nameSearch = nil, person_id = nil, page_to = nil)
    q = genQuery(MailHistory, nameSearch, filters, person_id, page_to)
    q.count
  end
  
  def self.findItems(rows=15, page=1, index=nil, sort_order='asc', filters = nil, nameSearch = nil, person_id = nil)
    q = genQuery(MailHistory, nameSearch, filters, person_id)
    
    offset = (page - 1) * rows.to_i
    if (index != nil && index != "")
       order_part = index + " " + sort_order
    else
       order_part = "people.last_name, people.first_name, mailings.id"
    end

    q.offset(offset).limit(rows).order(order_part)
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
    count = MailHistory.where(conditions).joins([ :person , :mailing ]).count

    if options[:per_page]
      per_page = options[:per_page]
      offset = (options[:page].to_i - 1) * options[:per_page].to_i
    else
      offset = 0
    end
    
    order = 'people.last_name, people.first_name, mailings.id'
    if options[:sort_by]
      order = @@mapping[options[:sort_by]] + " " + options[:order]
    end
    
    conditions = buildClause options

    MailHistory.where(conditions).joins([ :person , :mailing ]).
                order(order).
                offset(offset).
                limit(per_page)
  end

  #
  #
  #  
  def self.getNumberOfMailHistories(conditions = {}, options = {})
    conditions = self.buildClause options
    
    MailHistory.where(conditions).joins([ :person , :mailing ]).count
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

  def self.genQuery(obj, nameSearch, filters, person_id = nil, page_to = nil)
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

    personQuery = ' people.id = ? '
    clause = DataService.addClause( clause, personQuery, person_id) if person_id && ! person_id.empty?

    if nameSearch #&& ! nameSearch.empty?
      join_part = 'JOIN people ON people.id = mail_histories.person_id LEFT JOIN pseudonyms ON pseudonyms.person_id = people.id'
    else
      join_part =  [ :person, :mailing ]
    end

    obj.where(clause).joins(join_part)
  end
  
end
