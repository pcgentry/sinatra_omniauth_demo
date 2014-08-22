require 'omniauth/identity'
class User < OmniAuth::Identity::Models::ActiveRecord
  attr_accessible :email, :name, :password, :password_confirmation

  has_many :authentications

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :email, :presence   => true,
            :format     => { :with => email_regex },
            :uniqueness => { :case_sensitive => false }

  def self.create_with_omniauth(auth)

    random_pass = ([*('A'..'Z'),*('0'..'9')]-%w(0 1 I O)).sample(8).join

    if auth.provider == "identity"
      create(name: auth['info']['name'])
    elsif auth.provider == "facebook"
      # temp_email = auth['uid']+"@idonotexist.com"
      puts "creating fb account"
      create(name: auth['info']['nickname'], email: auth['info']['email'], password: random_pass )
    elsif auth.provider == "github"
      create(name: auth['info']['nickname'], email: auth['info']['email'], password: random_pass )
     elsif auth.provider == "twitter"
      #Unfortunate necessity.. need to add some code to prompt for email when they sign in.
      temp_email = auth['uid']+"@idonotexist.com"
      create(name: auth['info']['nickname'], email: temp_email, password: random_pass )
    end
  end





end