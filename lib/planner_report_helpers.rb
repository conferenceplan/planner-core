module PlannerReportHelpers
   require 'fastercsv'
   require 'iconv'
 
   def csv_out(data, filename)
      csv_data = FasterCSV.generate do |csv|
         data.each do |r|
            csv << r
         end
      end
      
      # This prevents keeping large strings in memory
      c = Iconv.new('ISO-8859-15//IGNORE','UTF-8')
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}\""
      render :content_type => 'text/csv; charset=iso-8859-1; header=present',
             :text => proc { |response, output|
         csv_data.each do |csvline|
            output.write(c.iconv(csvline))
         end
      }
   end

   def csv_out_utf16(data, filename)
      csv_data = FasterCSV.generate do |csv|
         data.each do |r|
            csv << r
         end
      end
      c = Iconv.new('UTF-16//IGNORE','UTF-8')
      send_data c.iconv(csv_data),
         :type => 'text/csv; charset=utf-16; header=present',
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
