#
#
#
class User < ActiveRecord::Base

  # include Authority::UserAbilities
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         # ,
         # :confirmable # allow the user to confirm and set their password
         
  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, 
                  :failed_attempts, :sign_in_count, :login, :reset_password_token,
                  :reset_password_sent_at, :confirmed_at, :confirmed_sent_at, :confirmation_token,
                  :last_request_at, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip,
                  :person_id, :remember_token, :remember_created_at, :unlock_token, :locked_at

  validates_uniqueness_of :login         

  #
  # TODO - change the role and access control mechanism
  #  
  has_many  :roleAssignments
  has_many  :roles, :through => :roleAssignments
  
  #
  #
  #
  def admin?
    return role_strings.include? 'Admin'
  end
  
  #
  # Use by declarative authorization to determine the permissions
  #
  # TODO - change to make use of the permission system i.e. map to roel for dec auth from role in db
  # i.e. user -> role -> role_authorization -> decl_auth
  #
  def role_symbols
   (roles || []).map {|r| r.title.to_sym }
  end
  
  def role_strings
   (roles || []).map {|r| r.title }
  end
  
  has_many :survey_queries

  #
  #
  #
  def password_match?
     self.errors[:password] << "can't be blank" if password.blank?
     self.errors[:password_confirmation] << "can't be blank" if password_confirmation.blank?
     self.errors[:password_confirmation] << "does not match password" if password != password_confirmation
     password == password_confirmation && !password.blank?
  end

  # new function to set the password without knowing the current 
  # password used in our confirmation controller. 
  def attempt_set_password(params)
    p = {}
    p[:password] = params[:password]
    p[:password_confirmation] = params[:password_confirmation]
    update_attributes(p)
  end

  # new function to return whether a password has been set
  def has_no_password?
    self.encrypted_password.blank?
  end

  # Devise::Models:unless_confirmed` method doesn't exist in Devise 2.0.0 anymore. 
  # Instead you should use `pending_any_confirmation`.  
  def only_if_unconfirmed
    pending_any_confirmation {yield}
  end

  #  
  # NOTE: we want to eventually migrate from SHA512
  # Meanwhile we have this to be backward compatible with Authlogic for the 'old' accounts
  #
  alias :devise_valid_password? :valid_password?
  def valid_password?(password)
    # debugger
    begin
      devise_valid_password?(password)
    rescue BCrypt::Errors::InvalidHash
        stretches = 20
        digest = [password, self.password_salt].flatten.join('')
        stretches.times {digest = Digest::SHA512.hexdigest(digest)}
        if digest == self.encrypted_password
          #Here update old Authlogic SHA512 Password with new Devise ByCrypt password
          # SOURCE: https://github.com/plataformatec/devise/blob/master/lib/devise/models/database_authenticatable.rb
          # Digests the password using bcrypt.
          # Default strategy for Devise is BCrypt
          # def password_digest(password)
          # ::BCrypt::Password.create("#{password}#{self.class.pepper}", :cost => self.class.stretches).to_s
          # end
          self.encrypted_password = self.password_digest(password)
          self.save
          return true
        else
          # If not BCryt password and not old Authlogic SHA512 password Dosn't my user
          return false
        end
    end
  end 
  
end
