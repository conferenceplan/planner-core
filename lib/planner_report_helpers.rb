module PlannerReportHelpers
   require 'fastercsv'
   require 'iconv'
 
   def csv_out(data, filename)
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

   def csv_out_noconv(data, filename)
      csv_data = FasterCSV.generate do |csv|
         data.each do |r|
            csv << r
         end
      end
      send_data csv_data,
         :type => 'text/csv; charset=utf-8; header=present',
         :disposition => "attachment; filename=#{filename}"
      flash[:notice] = "Export complete!"
      
   end

end
