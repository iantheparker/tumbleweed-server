desc "This task is called by the Heroku scheduler add-on"
task :unlock_time => :environment do
    puts "checking elapse time"
    #find all users at game_state[2]
    #fetch their last checkin
    # if greater than threshold, unlock level 2, 
    # send apn
    
    puts "done."
end
