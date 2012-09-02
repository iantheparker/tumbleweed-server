desc "This task is called by the Heroku scheduler add-on"
task :unlock_time => :environment do
    puts "checking elapse time for riverbed2"
    users = User.find_all_by_level(2)
    users.map { |user|
    	if user.checkins.last.updated_at < 2.hours.ago
    		device = APN::Device.find_by_token(user.device_token)
			message = "The next chapter of No Man's Land is ready for you."
			Rails.logger.info(message)
			user.send_push(device, message)
			puts user.first_name
			user.level =+ 1
			user.save
    	end
    }
    puts "done."
end
