class User < ActiveRecord::Base
	has_many :checkins, :dependent => :destroy
	
	def check_time_elapsed
		# get last checkin
		# compare time elapsed
		# if > 1.hour, send push, bump level
		#puts "check_time_elapsed"
	end
	
	def update_level
		self.level += 1
		save
		device = APN::Device.find_by_token(self.device_token)
		message = "You unlocked the next chapter of No Man's Land!"
		logger.info(message)
		send_push(device, message)
	end
	
	def send_push(device, message)
		notification=APN::Notification.new
		notification.device=device
		notification.badge=1
		notification.sound=true
		notification.alert=message
		notification.save
		Rails.logger.info("saved notification")
	end
	
end
