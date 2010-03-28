#
#
#
class Proto::MemberController < ApplicationController
  def create
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    
    if (@first_name)
      @member = Person.new
      @member.first_name = @first_name
      @member.last_name = @last_name
      @member.save
    end
   
  end

  def edit
  end

  def list
  end

  def view
  end

end
