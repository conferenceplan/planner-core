class UpdatePhoneNumbers < ActiveRecord::Migration
  def self.up
    # Go through the people and extract those that have a phone number in their address
    people = Person.find :all, :include => :postal_addresses, :conditions => 'postal_addresses.phone is not null'
    
    people.each do |person|
      person.postal_addresses.each do |addr|
        phone = person.phone_numbers.new
        phone.number = addr.phone
        phone.phone_type_id = PhoneTypes[:Home].id
      end
      person.save
    end
  end
  
  def self.down
  end
end
