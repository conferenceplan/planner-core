class PlannerApplicationController < ApplicationController
  
  def self.parameterized_before_filter(filter_name, *args)
    options = args.extract_options!

    self.before_filter(options) { |controller| controller.send(filter_name, *args) }
  end

  def planner_rest(*args)
    # get the arguments
  end

# TODO - add the rest based methods
  def edit
#    @postalAddress = PostalAddress.find(params[:id])
    render :layout => 'content'
  end

end

#  #################################################
#  # Sample usage with 2 parameters.
#  parameterized_before_filter :my_filter, 'param1', 'param2', :only => :create
#
#  #################################################
#  # Sample usage passing a hash as a parameter value.
#  parameterized_before_filter :my_filter, 'param1', 'param2',
#                                            { :param3 => :value3 }, :only => :create
