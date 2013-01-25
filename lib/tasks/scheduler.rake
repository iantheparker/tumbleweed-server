desc "This task is called by the Heroku scheduler add-on"
task :unlock_time => :environment do
    users = User.find_all_by_level(4)
    puts "checking elapse time for riverbed2 among " + users.count + " users"
    users.map { |user|
    	if user.checkins.last.updated_at < 2.hours.ago
    		user.update_level_with_apn()
    	end
    }
    puts "done."
end
