#
#
#
class PlannerReportsController < PlannerController
  include PlannerReportHelpers
  require 'fastercsv'
  
  def show
  end
  
  def index
  end

  def panels_date_form
  end
 
  def panels_with_panelists

    @outfile = "panels_" + Time.now.strftime("%m-%d-%Y") + ".csv"
 
    if params[:mod_date] == ''
       mod_date = '1900-01-01'
    else 
       mod_date = params[:mod_date]
    end

    panels = ProgrammeItem.all(:include => :people, :conditions => ["programme_items.updated_at >= ? or programme_item_assignments.updated_at >= ? or (programme_items.updated_at is NULL and programme_items.created_at >= ?) or (programme_item_assignments.updated_at is NULL and programme_item_assignments.created_at >= ?)", mod_date, mod_date, mod_date, mod_date], :order => "programme_items.id, people.last_name") 

    csv_data = FasterCSV.generate do |csv|
       csv << [
          "Panel",
          "Participants",
       ]
       panels.each do |panel|
         names = Array.new
         panel.people.each do |p|
            names.push p.GetFullName.strip
         end
         part_list = names.join(', ')
         csv << [
            panel.title,
            part_list
         ]
       end
     end

   send_data csv_data,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=#{@outfile}"

   flash[:notice] = "Export complete!"
    
  end

end
