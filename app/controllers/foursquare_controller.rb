class FoursquareController < ApplicationController

    def push
        # first just log the raw checkin from foursquare
        raw_checkin = RawCheckin.create(:payload => params['checkin'])

        checkin = JSON.parse(params['checkin'])
        checkin_id = checkin["id"]
        logger.info(checkin)

        venue = checkin["venue"]
        venue_id = venue["id"]
        venue_name = venue["name"]
        venue_cat = venue["categories"]
        venue_cat0 = venue_cat[0]
        if venue_cat0["name"] =~/Gas/
        	venue_cat_name = venue_cat0["name"]
        end
        venue_cat_parents = venue_cat0["parents"]
        venue_cat_id = venue_cat0["id"]
        puts venue_name, venue_cat_parents

        foursquare_user= JSON.parse(params['user'])
        foursquare_user_id = foursquare_user["id"]

        user = User.find_by_foursquare_id(foursquare_user_id)

        if user        
        	source_url = checkin_source(checkin_id, params={}, user.oauth_token)
        	if source_url =~ /tumbleweed/
        		# /tumbleweed/.match(source_url)
        		puts "totally from tumbleweed, just updating level"
        		#update Level
        		puts "user level was " + user.level.to_s
        		user.update_attributes(:level => (user.level +=1))
        		puts "user level is now " + user.level.to_s
        	else
        		#gamestate - does this checkin unlock the next level?
        		checkin_reply(checkin_id, params={:text => "You unlocked the next chapter!"}, user.oauth_token)
        		device = APN::Device.find_by_token(user.device_token)
            	message = "Your checkin at " + venue_name + " unlocked the next chapter of No Man's Land!"
            	logger.info(message)
            	send_push(device, message)
        	end
        end

        v = Venue.find_by_foursquare_id(venue_id)
        if v.nil?
            v = Venue.create(:foursquare_id => venue_id, :name => venue_name, :user_id => user.id)
        end

        render :text => "got push"
    end
        
    def updateLevel #the route for the app - gonna have to go
    	@id = params['tumbleweedID']
    	@user = User.find_by_id(@id)
       	@user.update_attributes(:level => (@user.level +=1))
    end
 
    def game_state
    	#if this game state && if checkin happened off of ios app && if checkin is under this parent category
    	#yes - update level, connected app message 'success', send push notification
    	#no - if not using foursquare mobile, then don't reply to checkin
    	categories = ["intro", 
    				"Shops & Services",
    				"Food OR Nightlife Spots", 
    				"Travel & Transport OR Shops & Services", 
    				"Great Outdoors", 
    				"riverbed2", 
    				"desertchase", 
    				"desertlynch",
    				"campfire"]
    	#have to send unlock message to to app for scenes
    end
    
    def checkin_source (checkin_id, params={}, oauth_token)
    	@checkin_id = checkin_id
      	params = {}.merge!(params)

      	response = perform_graph_request("checkins/#{@checkin_id}", params, "get", oauth_token)
      	response = response["response"]
      	checkin = response["checkin"]
      	source = checkin["source"]
      	source_url = source["url"]
      	puts "source_url is " + source_url.to_s
      	return source_url
    end
    
    def checkin_reply(checkin_id, params={}, oauth_token)
      	@checkin_id = checkin_id
      	params = {:text => "Tumbleweed rules!",
      		:url => "http://tumbleweed.me",
            :v => "20120813"}.merge!(params)

      	response = perform_graph_request("checkins/#{@checkin_id}/reply", params, "post", oauth_token)
      	puts "checkin_reply response:", response
    end
    
    def perform_graph_request(endpoint, params={}, method="get", oauth_token)
      	require 'net/http'
      	@access_token = oauth_token
      	@base_url = "https://api.foursquare.com:443/v2/"

      	@query_string = "?"
      	@query_string += "oauth_token=#{CGI.escape(@access_token)}" unless @access_token.empty?

      	if method=="get"
        	params.each{|key, val| @query_string += "&#{key}=#{val}"}
        	url = URI.parse("#{@base_url}#{endpoint}#{@query_string}")
        	request = Net::HTTP::Get.new("#{url.path}?#{url.query}",{"Content-Type"=>"text/json"})
      	else
        	url = URI.parse("#{@base_url}#{endpoint}#{@query_string}")
        	request = Net::HTTP::Post.new("#{url.path}?#{url.query}",{"Content-Type"=>"text/json"})
        	request.set_form_data(params)
      	end

      	http = Net::HTTP.new(url.host, url.port)
      	http.use_ssl = true
      	response = JSON.parse(http.start {|http| http.request(request)}.body)
      	return response
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
