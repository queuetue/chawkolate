require 'json'
class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :lockable, :rememberable, :trackable, :omniauthable, omniauth_providers: [:google_oauth2]
	after_create :create_agent
	after_create :create_api_key

	has_many :api_keys
	belongs_to :agent, class_name: "Chawk::Models::Agent"

	def self.find_for_google_oauth(auth)
	  where(auth.slice(:provider, :uid)).first_or_create do |user|
	      user.provider = auth.provider
	      user.uid = auth.uid
	      user.provider_email = auth.info.email
	      user.email = auth.info.email
	      user.name = auth.info.name
	      user.image_url = auth.info.picture
	  end
	end


private
	def create_agent
		self.agent = Agent.create(name:self.uid)
		save
	end
	
	def create_api_key
		self.api_client_id = SecureRandom.hex
		self.api_keys << ApiKey.create 
		save
	end
end
