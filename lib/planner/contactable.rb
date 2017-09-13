require 'active_support/concern'

module Planner
  module Contactable
    extend ActiveSupport::Concern

    module ClassMethods
      def has_contact_info through: Address, types: [:email_address, :postal_address, :phone_number]

        has_many :addresses, :class_name => through.to_s, :dependent => :delete_all

        if types.is_a?(Array) && types.any?
          types.each do |type|
              type = type.to_s.downcase
              case type
                ## Postal Addresses ##
                when 'postal_addresses', 'postal_address', 'postal', 'postal address', 'postal addresses', 'postaladdress'
                  has_many  :postal_addresses, :through => :addresses,
                        :source => :addressable, 
                        :source_type => 'PostalAddress'
                  accepts_nested_attributes_for :postal_addresses

                  send(:define_method, 'addressMatch?') do |new_line1, new_city, new_state, new_postcode, new_country|
                    address = getDefaultPostalAddress()

                    if address
                      if ((address.line1 == new_line1) &&
                         (address.city == new_city) &&
                         (address.state == new_state) &&
                         (address.postcode == new_postcode) &&
                         (address.country == new_country))
                         return true
                      else
                        return false
                      end
                    else
                      return false
                    end
                  end

                  send(:define_method, 'getDefaultPostalAddress') do
                    possibleAddresses = postal_addresses
                    theAddress = nil
                    if possibleAddresses
                      possibleAddresses.each do |addr| 
                        if addr.isdefault
                          theAddress = addr
                        else # if the address is empty we want to take the first one (unless there is a default)
                          if theAddress == nil
                            theAddress = addr
                          end
                        end
                      end
                    end
                    return theAddress
                  end

                  send(:define_method, 'updateDefaultAddress') do |new_line1, new_city, new_state, new_postcode, new_country|
                    # We will create a new address object and make that the default (so the old one will no longer be used but will still be in the list)
                    address = getDefaultPostalAddress
                    
                    if address
                      address.isdefault = false
                      address.save!
                    end
                    
                    self.postal_addresses.new :line1 => new_line1, :city => new_city, :state => new_state, :postcode => new_postcode, :country => new_country, :isdefault => true 

                    self.save!
                  end

                  send(:define_method, 'replaceDefaultAddress') do |new_line1, new_line2, new_city, new_state, new_postcode, new_country, new_state_code, new_country_code|
                    # We will create a new address object and make that the default (so the old one will no longer be used but will still be in the list)
                    address = getDefaultPostalAddress
                    
                    if address
                      address.line1 = new_line1
                      address.line2 = new_line2
                      address.city = new_city
                      address.state = new_state if !new_state.blank?
                      address.postcode = new_postcode
                      address.country = new_country if !new_country.blank?
                      address.state_code = new_state_code
                      address.country_code = new_country_code
                      address.save!
                    else
                      postalAddress = self.postal_addresses.create :line1 => new_line1, 
                                                    :line2 => new_line2, 
                                                    :city => new_city, 
                                                    # :state => new_state, 
                                                    :postcode => new_postcode, 
                                                    # :country => new_country, 
                                                    :state_code => new_state_code,
                                                    :country_code => new_country_code,
                                                    :isdefault => true 
                      postalAddress.state = new_state if !new_state.blank?
                      postalAddress.country = new_country if !new_country.blank?
                      postalAddress.save
                    end

                    self.save!
                    self
                  end

                  send(:define_method, 'removePostalAddress') do |address|
                     postal_addresses.delete(address) # remove it from the person
                     # and then make sure that it is not used by another person
                     if through.column_names.include?('person_id')
                       if (! addresses.where(["addressable_id = ? and person_id != ?", address, @id]) )
                         address.destroy
                       end
                     else
                      address.destroy
                     end
                  end

                ## Email Addresses ##
                when 'email_addresses', 'email_address', 'email', 'email address', 'email addresses', 'emailaddress'
                  has_many  :email_addresses, :through => :addresses, 
                            :source => :addressable, 
                            :source_type => 'EmailAddress'
                  accepts_nested_attributes_for :email_addresses

                  send(:define_method, 'emailMatch?') do |email|
                    e = getDefaultEmail()
                    
                    return e ? e.email == email : false
                  end

                  send(:define_method, 'updateDefaultEmail') do |email, label: nil, save: true|
                    e = getDefaultEmail()
                    if e
                      e.isdefault = false
                      e.save!
                    end
                  
                    e = self.email_addresses.new :email => email, label: label, :isdefault => true 
                   
                    self.save! if save
                  end

                  send(:define_method, 'getDefaultEmail') do
                    possibleEmails = email_addresses
                    theEmail = nil
                    if possibleEmails
                      possibleEmails.each do |email| 
                        if email.isdefault
                          theEmail = email
                        else # if the email is empty we want to take the first one (unless there is a default)
                          if theEmail.nil?
                            theEmail = email
                          end
                        end
                      end
                    end
                    return theEmail
                  end

                  send(:define_method, 'default_email_address') do
                    address = getDefaultEmail
                    address.present? && address.email.present? ? address.email.strip : nil
                  end

                  send(:define_method, 'hasDefaultEmail?') do
                    address = getDefaultEmail
                    address.present? && address.email.present?
                  end

                  send(:define_method, 'removeEmailAddress') do |address|
                     email_addresses.delete(address) # remove it from the person
                     # and then make sure that it is not used by another person
                      if through.column_names.include?('person_id')
                        if (! addresses.where(["addressable_id = ? and person_id != ?", address, @id]) )
                          address.destroy
                        end
                      else
                        address.destroy
                      end
                  end

                ## Phone Numbers ##
                when 'phone_numbers', 'phone_number', 'phone', 'phone number', 'phone numbers', 'phonenumber'
                  has_many :phone_numbers, :through => :addresses,
                            :source => :addressable,
                            :source_type => 'PhoneNumber'
                  accepts_nested_attributes_for :phone_numbers

                  send(:define_method, 'updatePhone') do |new_phone, phonetype|
                    # first find the existing phone of the given type
                    # if found update it
                    # otherwise create a new instance
                    phone = phone_numbers.detect { |ph| ph.phone_type == PhoneTypes[phonetype] }# findPhoneByType(phonetype)
                    if phone
                      phone.number = new_phone
                      phone.save!
                    else
                      phone = self.phone_numbers.new :number => new_phone
                      phone.number = new_phone
                      phone.phone_type = PhoneTypes[phonetype]
                      self.save!
                    end
                  end

                  send(:define_method, 'updateDefaultPhoneNumber') do |number, phone_type_id: nil, label: nil, save: true|
                    e = getDefaultPhoneNumber()
                    if e
                      e.isdefault = false
                      e.save!
                    end
                  
                    e = self.phone_numbers.new :number => number, phone_type_id: phone_type_id, label: label, :isdefault => true 
                   
                    self.save! if save
                  end

                  send(:define_method, 'getDefaultPhoneNumber') do
                    possiblePhoneNumbers = phone_numbers
                    thePhoneNumber = nil
                    if possiblePhoneNumbers
                      possiblePhoneNumbers.each do |number| 
                        if number.isdefault
                          thePhoneNumber = number
                        else # if the number is empty we want to take the first one (unless there is a default)
                          if thePhoneNumber.nil?
                            thePhoneNumber = number
                          end
                        end
                      end
                    end
                    return thePhoneNumber
                  end

                  send(:define_method, 'hasDefaultPhoneNumber?') do
                    phone = getDefaultPhoneNumber
                    phone.present? && phone.number.present?
                  end

                  send(:define_method, 'default_phone_number') do
                    phone = getDefaultPhoneNumber
                    phone.present? && phone.number.present? ? phone.number.strip : nil
                  end
              end


              send(:define_method, 'removeAllAddresses') do
                if self.respond_to?(:postal_addresses)
                  # Get the addresses and if they are not reference by other people the get rid of them...
                  postalAddresses = self.postal_addresses
                  
                  if (postalAddresses)
                    postalAddresses.each do |address|
                      self.removePostalAddress(address)
                    end
                  end
                end

                if self.respond_to?(:email_addresses)
                  emailAddresses = self.email_addresses
                  if (emailAddresses)
                    emailAddresses.each do |eaddress|
                      self.removeEmailAddress(eaddress)
                    end
                  end
                end
              end

          end
        end

      end
    end

  end
end

ActiveRecord::Base.send(:include, Planner::Contactable)

