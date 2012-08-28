class FoursquareController < ApplicationController

    def push
        # first just log the raw checkin from foursquare
        raw_checkin = RawCheckin.create(:payload => params['checkin'])

        checkin = JSON.parse(params['checkin'])
        checkin_id = checkin["id"]
        logger.info(checkin)

        venue = checkin["venue"]
        venue_name = venue["name"]
        #if gas don't save parents - A Gas station checkin should only unlock the gas scene
        venue_cat_parents = venue["categories"][0]["parents"]
        venue_type = venue_cat_parents << venue_name
        puts venue_type

        foursquare_user= JSON.parse(params['user'])
        foursquare_user_id = foursquare_user["id"]

        user = User.find_by_foursquare_id(foursquare_user_id)
        if user.nil?
        	return
        end        
        checkin_levels = 4 #number of foursquare venues to check in to before riverbed2
        last_checkin_level = 8

        if user.level <= checkin_levels || user.level == last_checkin_level
			if game_state(user.level, venue_name, venue_cat_parents[0]).nil?
				checkin_reply(checkin_id, params={:text => "Not gonna find the next chapter of No Man's Land here..."}, user.oauth_token)
			else
				checkin_reply(checkin_id, params={:text => "You unlocked the next chapter!"}, user.oauth_token)
				source_url = checkin_source(checkin_id, params={}, user.oauth_token)
				if /tumbleweed/.match(source_url).nil?
					# if user didn't check in using the iOS app, then send a push notification
					device = APN::Device.find_by_token(user.device_token)
					message = "Your checkin at " + venue_name + " unlocked the next chapter of No Man's Land!"
					logger.info(message)
					send_push(device, message)
				end
				successful_checkin = Checkin.create(:user_id => user_id,
            										:checkin_id => checkin_id,
            										:milestone_id => milestone,
            										:venue_name => venue_name,
            										:venue_category => venue["categories"][0],
            										:venue_id => venue["id"])
			end	
        else
        	puts "user isn't at a foursquare level" + user.level.to_s 
        end
        
        render :text => "got push"
    end

    def process_nonlinear_checkin(checkin_category, user_id)
        deal = "deal"
        saloon = "saloon"
        gas = "gas"
        
        category_map = {
            deal => ["Shops & Services"],
        	saloon => ["Food", "Nightlife Spots"],
        	gas => ["Travel & Transport", "Gas Station"]
        }

        milestones = [deal, saloon, gas]
        checkins = Checkin.find_all_by_user_id(user_id)
        checked_milestones = checkins.map {|c| c.milestone_id}
        
        remaining = milestones - checked_milestones
        if checkin_category.join(" ") =~ /Gas/ && remaining.join(" ") =~ /#{gas}/
        	return gas
        end
        remaining.each do |milestone|
           categories = category_map[milestone] 
           categories.map { |category|
            	# add for each position in the categories array, check if they statisfied, if so add record to UserCheckins
            	if checkin_category.join(" ") =~ /#{category}/
            		puts "successful unlock of " + milestone + " chapter"
            		if remaining.count == 1
            			user.level += 1
            		end
            	unlocked = milestone            	
            	end
            }
        end
        return unlocked
    end

    def process(user)
        case user.level
        when 0
           # check non linear checkins 
           return process_nonlinear_checkin(category, user.user_id)
        when 1
            # check if they satisfied great outdoors
            riverbed1 = ["Great Outdoors"]
            if checkin_category.join(" ") =~ /#{riverbed1}/
            	user.level += 1
            end
        when 2
            #time-based
        when 3
            #distance
        when 4
        	#somewhere new
        when 5
        	#game over
        end
        user.update_attributes(:level => (user.level +=1))
    end
        
    def updateLevel
    	#in case of foursquare push failure, should detect which was updated more recently before updating level, app or server
    	#keep this in sync and connected with /register?
    	@id = params['tumbleweedID']
    	@user = User.find_by_id(@id)
       	@user.update_attributes(:level => (@user.level +=1))
    end
 
    def game_state(level, venue_name, venue_cat_parents)
    	#if this game state is accessible && if checkin is under this parent category (or a gas station)
    	#yes - update level, connected app message 'success', send push notification
    		# if checkin is one of our special venues, treat separately
    	#no - send a hint of the right type of checkin category as the reply
    	#have to send unlock message to the app for scenes

    	@level = level
    	@venue_name = venue_name
    	@venue_cat_parents =  venue_cat_parents

    	game_stater = ["Shops & Services",
    				"Food OR Nightlife Spots", 
    				"Travel & Transport OR Gas", 
    				"Great Outdoors"]
    	
    	return /#{@venue_name}/.match(game_stater[@level]) || /#{@venue_cat_parents}/.match(game_stater[@level])
    end
    
    def checkin_source(checkin_id, params={}, oauth_token)
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
    
    def add_photo(params={}, file="")
      require 'rest_client'

      params = {:checkinId => "",
                :tipId => "",
                :venueId => "",
                :broadcast => "",
                :ll => "",
                :llAcc => "",
                :alt => "",
                :altAcc => "",
                :file => File.new(file)}

      RestClient.post('https://api.foursquare.com/v2/photos/add', params)
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


end
