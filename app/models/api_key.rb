class ApiKey < ActiveRecord::Base
	before_create :generate_access_token
	before_create :set_expires
	belongs_to :user

	def expired?
		Time.now > expires
	end

	def active?
		Time.now <= expires
	end

private

	def set_expires
		self.expires = Time.now + 14.days
	end

	def generate_access_token
		begin
			self.access_token = SecureRandom.hex
		end while self.class.exists?(access_token:access_token)
	end
end
