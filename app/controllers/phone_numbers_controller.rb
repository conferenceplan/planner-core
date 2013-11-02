class PhoneNumbersController < PlannerController

  def update
    phoneNumber = PhoneNumber.find(params[:id])

    phoneNumber.update_attributes(params[:phone_number])

    render json: phoneNumber.to_json, :content_type => 'application/json'
  end

  def create
    if (params[:person_id])
      person = Person.find(params[:person_id])      
      phoneNumber = person.phone_numbers.new(params[:phone_number])
      person.save!
    else
      # CHECK - we may not want to create an address without having a person to assigned it to it?
      phoneNumber = PhoneNumber.new(params[:phone_number]);
      phoneNumber.save!
    end

    render json: phoneNumber.to_json, :content_type => 'application/json'
  end

  def show
    phoneNumber = PhoneNumber.find(params[:id])

    render json: phoneNumber.to_json, :content_type => 'application/json'
  end

  def destroy
    # TODO - make sure that this cleans up the relationships in the Address table
    # TODO - this is not correct, the number should be removed from the person then only
    # destroyed if there are no other people referencing the address...
    phoneNumber = PhoneNumber.find(params[:id])
    phoneNumber.destroy
    render status: :ok, text: {}.to_json
  end

  def index
    person = Person.find(params[:person_id])
   
    @phoneNumbers = person.phone_numbers
    
    # render json: @phoneNumbers.to_json, :content_type => 'application/json'
  end
end
