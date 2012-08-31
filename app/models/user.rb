class User < ActiveRecord::Base
	has_many :checkins, :dependent => :destroy
	
	def check_time_elapsed
		# get last checkin
		# compare time elapsed
		# if > 1.hour, send push, bump level
		#puts "check_time_elapsed"
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
