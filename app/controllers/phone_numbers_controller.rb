class PhoneNumbersController < PlannerController

  def update
    @phone = PhoneNumber.find(params[:id])

    @phone.update_attributes(params[:phone_number])
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  def create
    if (params[:person_id])
      person = Person.find(params[:person_id])      
      @phone = person.phone_numbers.new(params[:phone_number])
      person.save!
    else
      # CHECK - we may not want to create an address without having a person to assigned it to it?
      @phone = PhoneNumber.new(params[:phone_number]);
      phoneNumber.save!
    end
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  def show
    @phone = PhoneNumber.find(params[:id])
  end

  def destroy
    # TODO - make sure that this cleans up the relationships in the Address table
    # TODO - this is not correct, the number should be removed from the person then only
    # destroyed if there are no other people referencing the address...
    phoneNumber = PhoneNumber.find(params[:id])
    phoneNumber.destroy
    render status: :ok, text: {}.to_json
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  def index
    person = Person.find(params[:person_id])
   
    @phoneNumbers = person.phone_numbers
  rescue => ex
    render status: :bad_request, text: ex.message
  end
end
