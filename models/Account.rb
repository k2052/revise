class Account
  include MongoMapper::Document
  revise :authenticatable, :database_authenticatable, :confirmable, :recoverable, :invitable

  # Keys
  key :name,                   String
  key :first_name,             String
  key :last_name,              String
  key :username,               String
  key :email,                  String
  key :encrypted_password,     String
  key :role,                   String  

  ## Confirmations
  key :confirmation_token,     String
  key :confirmed_at,           Time
  key :unconfirmed_email,      String
  key :confirmation_sent_at,   Time

  ## Recovery
  key :reset_password_sent_at, Time
  key :reset_password_token,   String
  
  ## Invitations
  key :invitation_token,       String
  key :invitation_sent_at,     Time 
  key :invitation_accepted_at, Time 
  key :invitation_limit,       Integer
  key :invited_by_id,          ObjectId

  ##
  # Validations
  #
  validate :username_format
  validates_uniqueness_of :email
  validate :email_format
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?

  def username_format
    errors.add(:username, 'Invalid Username') if self.username == 'invalid_username'
  end

  def email_format
    errors.add(:email, 'Invalid Email') if self.email == 'invalid_email'
  end

  def name
    return "#{self.first_name}, #{self.last_name}" unless self.first_name.nil? 
    return ""
  end
 
  def name=(n) 
    n = n.split(",").join(" ").split(" ").uniq      
    self.first_name = n[0] if n.length > 0
    self.last_name  = n[1] if n.length >= 1
  end 
end
