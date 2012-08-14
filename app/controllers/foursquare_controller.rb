require 'net/http'

class FoursquareController < ApplicationController

    def push
        # first just log the raw checkin from foursquare
        raw_checkin = RawCheckin.create(:payload => params['checkin'])

        checkin = JSON.parse(params['checkin'])
        checkin_id = checkin["id"]
        
        checkin_source(checkin_id)

        logger.info(checkin)
 		
        #source = checkin["source"]
        #source_url = source["url"]
        #logger.info(source_url)
        
        venue = checkin["venue"]
        venue_id = venue["id"]
        venue_name = venue["name"]
        #venue_cat = venue["categories"]
        #venue_cat_id = venue_cat["id"]
        #logger.info(venue_cat_id)

        foursquare_user= JSON.parse(params['user'])
        foursquare_user_id = foursquare_user["id"]

        user = User.find_by_foursquare_id(foursquare_user_id)

        if user
        	checkin_reply(checkin_id, user.oauth_token)
            device = APN::Device.find_by_token(user.device_token)
            message = "You checked in on foursquare at " + venue_name
            logger.info(message)
            #send_push(device, message)
        end

        usermessage = "user id is " + user.id.to_s
        logger.info(usermessage)
        v = Venue.find_by_foursquare_id(venue_id)
        if v.nil?
            v = Venue.create(:foursquare_id => venue_id, :name => venue_name, :user_id => user.id)
        end

        render :text => "got push"
    end
        
    def updateLevel
    	@id = params['tumbleweedID']
    	@user = User.find_by_id(@id)
       	@user.update_attributes(:level => (@user.level +=1))
        
       	render :json => @user.level 
    end
    
    def game_state
    	#if this game state && if checkin happened off of ios app && if checkin is under this parent category
    	#yes - update level, connected app message 'success', send push notification
    	#no - if not using foursquare mobile, then don't reply to checkin
    end
    
    def checkin_reply(checkin_id, oauth_token)
    	@checkin_id = checkin_id  
    	@oauth_token = oauth_token
    		
    	params = {:text => "Tumbleweed rules!",
                :url => "http://tumbleweed.me"}
                #tumbleweed app launch

    	query_string = "?oauth_token=#{@oauth_token}"
    	
    	url = URI.parse("https://api.foursquare.com/v2/checkins/#{@checkin_id}/reply#{query_string}")
        request = Net::HTTP::Post.new("#{url.path}?#{url.query}",{"Content-Type"=>"text/json"})
        request.set_form_data(params)
      
      	http = Net::HTTP.new(url.host, url.port)
      	http.use_ssl = true
      	response = JSON.parse(http.start {|http| http.request(request)}.body)
      	response
      	#render :json => response
    end
    
    def checkin_source(checkin_id)
    	url = URI.parse("https://api.foursquare.com/v2/checkins/#{@checkin_id}?oauth_token=#{checkin_id}") 
		request = Net::HTTP::Get.new("#{url.path}?#{url.query}",{"Content-Type"=>"text/json"})
		http = Net::HTTP.new(url.host, url.port)
      	http.use_ssl = true
      	response = JSON.parse(http.start {|http| http.request(request)}.body)
      	response
      	#render :json => response
      	logger.info(response)
    end

    protected     
    def send_push(device, message)
    	notification=APN::Notification.new
        notification.device=device
        notification.badge=1
        notification.sound=true
        notification.alert=message
        notification.save
    end

end
