class Account
  include MongoMapper::Document
  revise :authenticatable, :database_authenticatable, :confirmable, :recoverable

  # Keys
  key :name,                   String
  key :first_name,             String
  key :last_name,              String
  key :surname,                String
  key :email,                  String
  key :encrypted_password,     String
  key :role,                   String  
  key :confirmation_token,     String
  key :confirmed_at,           Time
  key :confirmation_sent_at,   Time
  key :reset_password_sent_at, Time
  key :reset_password_token,   String
  key :unconfirmed_email,      String

  def name()  
    return "#{self.first_name}, #{self.last_name}" unless self.first_name.nil? 
    return ""
  end
 
  def name=(n) 
    n = n.split(",").join(" ").split(" ").uniq      
    self.first_name = n[0] if n.length > 0
    self.last_name  = n[1] if n.length >= 1
  end 

  def archive()
    doc = self.to_mongo
    Archive.collection.save(doc, :safe => true) 
    return self.destroy
  end
end