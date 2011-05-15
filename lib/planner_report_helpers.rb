module PlannerReportHelpers
   require 'fastercsv'
   require 'iconv'
 
   def csv_out(data, filename)
logger.debug "fn: #{filename}"
      csv_data = FasterCSV.generate do |csv|
         data.each do |r|
            csv << r
         end
      end
      c = Iconv.new('ISO-8859-15//IGNORE','UTF-8')
      send_data c.iconv(csv_data),
         :type => 'text/csv; charset=iso-8859-1; header=present',
         :disposition => "attachment; filename=#{filename}"
      flash[:notice] = "Export complete!"
      
   end

end
