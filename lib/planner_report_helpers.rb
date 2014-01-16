module PlannerReportHelpers
   require 'csv'
 
   def csv_out(data, filename)
      csv_data = CSV.generate encoding: 'ISO-8859-15' do |csv|
         data.each do |r|
            csv << r
         end
      end
      send_data csv_data.encode('ISO-8859-15', :invalid => :replace, :undef => :replace),
         :type => 'text/csv; charset=iso-8859-15; header=present',
         :disposition => "attachment; filename=#{filename}"
      flash[:notice] = "Export complete!"
   end

   def csv_out_utf16(data, filename)
      csv_data = CSV.generate :encoding => 'UTF-16' do |csv|
         data.each do |r|
            csv << r
         end
      end
      send_data csv_data.encode('UTF-16', :invalid => :replace, :undef => :replace),
         :type => 'text/csv; charset=utf-16; header=present',
         :disposition => "attachment; filename=#{filename}"
      flash[:notice] = "Export complete!"
   end

   def csv_out_noconv(data, filename)
      csv_data = CSV.generate do |csv|
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
