class User < ApplicationRecord
	has_many :microposts, dependent: :destroy
	attr_accessor :remember_token
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	before_save { email.downcase! }
	validates :name, presence: true, length: { maximum: 50 }
	validates :email, presence: true,  length: { maximum: 255 },
	uniqueness: { case_sensitive: false }, format: { with: VALID_EMAIL_REGEX }
	has_secure_password
	validates :password, presence: true, length: { minimum: 6 }

	def User.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
		BCrypt::Engine.cost
		BCrypt::Password.create(string, cost: cost)
	end

	  # Returns a random token.
	  def User.new_token
	  	SecureRandom.urlsafe_base64
	  end

	  # Remembers a user in the database for use in persistent sessions.
	  def remember
	  	self.remember_token = User.new_token
	  	update_attribute(:remember_digest, User.digest(remember_token))
	  end

	  # Returns true if the given token matches the digest.
	  def authenticated?(remember_token)
	  	remember_digest ? BCrypt::Password.new(remember_digest).is_password?(remember_token) :
	  	false
	  end

	   # Forgets a user.
	   def forget
	   	update_attribute(:remember_digest, nil)
	   end

	   def feed
	   	Micropost.where("user_id = ?", id)
	   end
	end
