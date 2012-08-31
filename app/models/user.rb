class User < ActiveRecord::Base
	has_many :checkins, :dependent => :destroy
	
	def check_time_elapsed
		# get last checkin
		# compare time elapsed
		# if > 1.hour, send push, bump level
		#puts "check_time_elapsed"
	end
	
end
