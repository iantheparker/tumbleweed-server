class FoursquareController < ApplicationController

    def push
        # first just log the raw checkin from foursquare
        raw_checkin = RawCheckin.create(:payload => params['checkin'])

        checkin = JSON.parse(params['checkin'])
        checkin_id = checkin["id"]
        logger.info(checkin)

        venue = checkin["venue"]
        venue_name = venue["name"]
        venue_cat_parents = venue["categories"][0]["parents"]
        venue_type = venue_cat_parents << venue_name
        puts venue_type

        foursquare_user= JSON.parse(params['user'])
        foursquare_user_id = foursquare_user["id"]

        user = User.find_by_foursquare_id(foursquare_user_id)
        if user.nil?
        	return
        end        

		unlocked_milestone, checkin_text = process_checkin(user, venue_type)
		if checkin_text
			checkin_reply(checkin_id, params={:text => checkin_text}, user.oauth_token)
		end
		if unlocked_milestone
			source_url = checkin_source(checkin_id, params={}, user.oauth_token)
			if /tumbleweed/.match(source_url).nil?
				# if user didn't check in using the iOS app, then send a push notification
				device = APN::Device.find_by_token(user.device_token)
				message = "Your checkin at " + venue_name + " unlocked the next chapter of No Man's Land!"
				logger.info(message)
				send_push(device, message)
			end
			successful_checkin = Checkin.create(:user_id => user.id,
												:checkin_id => checkin_id,
												:milestone_id => unlocked_milestone,
												:venue_name => venue_name,
												:venue_category => venue["categories"][0],
												:venue_id => venue["id"])
		end	
		
        render :text => "got push"
    end
  
    def process_checkin(user, categories=[])
    	unlocked = nil
    	checkin_text = nil
    	
        case user.level
        when 0 
           # check non linear checkins 
           unlocked = process_nonlinear_checkin(user, categories)
           checkin_text = "reply"
        when 1 
            # check if they satisfied great outdoors
            riverbed1 = "Great Outdoors"
            if categories.join(" ") =~ /#{riverbed1}/
            	unlocked = "riverbed1"
            	user.update_attributes(:level => (user.level +=1))
            end
            checkin_text = "reply"
        when 2 
            puts "time-based level"
        when 3 
            puts "distance-based level"
        when 4 
        	#somewhere new
        	checkin_text = "reply"
        when 5 
        	#game over
        end
        
        #checkin_text will be non-nil if user is at appropriate level
        if checkin_text && unlocked
        	checkin_text =  "You unlocked the next chapter of No Man's Land!"
        elsif checkin_text
        	checkin_text =  "Not gonna find the next chapter of No Man's Land here..."
        end
        
        # if categories is empty, it means this wasn't called from a checkin
        if categories.empty?
        	return unlocked
        else
        	return unlocked, checkin_text
        end
    end

    def process_nonlinear_checkin(user, checkin_category)
        unlocked = nil
        
        deal = "deal"
        saloon = "saloon"
        gas = "gas"
        
        category_map = {
            deal => ["Shops & Services"],
        	saloon => ["Food", "Nightlife Spots"],
        	gas => ["Travel & Transport", "Gas Station"]}

        milestones = [deal, saloon, gas]
        checkins = Checkin.find_all_by_user_id(user.id)
        checked_milestones = checkins.map {|c| c.milestone_id}
        
        remaining = milestones - checked_milestones
        # if they checked in to a gas station and the gas scene is locked, hit that case first
        if checkin_category.join(" ") =~ /Gas/ && remaining.join(" ") =~ /#{gas}/
        	return gas
        end
        remaining.each do |milestone|
           categories = category_map[milestone] 
           categories.map { |category|
            	if checkin_category.join(" ") =~ /#{category}/
            		puts "successful unlock of " + milestone + " chapter"
            		if remaining.count == 1
            			user.update_attributes(:level => (user.level +=1))
            		end
            		unlocked = milestone            	
            	end
            }
        end
        return unlocked
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
