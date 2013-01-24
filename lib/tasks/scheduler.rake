desc "This task is called by the Heroku scheduler add-on"
task :unlock_time => :environment do
    puts "checking elapse time for riverbed2"
    users = User.find_all_by_level(4)
    users.map { |user|
    	if user.checkins.last.updated_at < 2.hours.ago
    		user.update_level_with_apn()
    	end
    }
    puts "done."
end
