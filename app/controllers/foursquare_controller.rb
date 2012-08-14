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
        #venue_cat = venue["categories"]
        #venue_cat_parent = venue_cat["parent"]
        #venue_cat_id = venue_cat["id"]
        #logger.info(venue_cat_id)

        foursquare_user= JSON.parse(params['user'])
        foursquare_user_id = foursquare_user["id"]

        user = User.find_by_foursquare_id(foursquare_user_id)

        if user        
        	source_url = checkin_source(checkin_id, params={}, user.oauth_token)
        	if source_url =~ /tumbleweed/
        		# /tumbleweed/.match(source_url)
        		puts "totally from tumbleweed"
        		updateLevel(user.id)
        	else
        		#gamestate - does this checkin unlock the next level?
        		#checkin_reply(checkin_id, user.oauth_token) #with success message
        		checkin_reply(checkin_id, params={:text => "You unlocked the next chapter!"}, user.oauth_token)
        		device = APN::Device.find_by_token(user.device_token)
            	message = "You checked in on foursquare at " + venue_name
            	logger.info(message)
            	#send_push(device, message)
        	end
        end

        usermessage = "user id is " + user.id.to_s
        logger.info(usermessage)
        v = Venue.find_by_foursquare_id(venue_id)
        if v.nil?
            v = Venue.create(:foursquare_id => venue_id, :name => venue_name, :user_id => user.id)
        end

        #render :text => "got push"
    end
        
    def updateLevel #the route for the app - gonna have to go
    	@id = params['tumbleweedID']
    	@user = User.find_by_id(@id)
       	@user.update_attributes(:level => (@user.level +=1))
        
       	#render :json => @user.level 
    end
    
    update_level(id)
    	@id = id
    	@user = User.find_by_id(@id)
       	@user.update_attributes(:level => (@user.level +=1))
    end
    
    def game_state
    	#if this game state && if checkin happened off of ios app && if checkin is under this parent category
    	#yes - update level, connected app message 'success', send push notification
    	#no - if not using foursquare mobile, then don't reply to checkin
    	#categories = ["no",]
    end
    
    def checkin_source (checkin_id, params={}, oauth_token)
      @checkin_id = checkin_id
      params = {}.merge!(params)

      response = perform_graph_request("checkins/#{@checkin_id}", params, "get", oauth_token)
      response = response["response"]
      checkin = response["checkin"]
      source = checkin["source"]
      source_url = source["url"]
      #render :json => source_url
      logger.info(source_url)
      return source_url
    end
    
    def checkin_reply(checkin_id, params={}, oauth_token)
      @checkin_id = checkin_id
      params = {:text => "Tumbleweed rules!",
                :url => "tumbleweed://",
                :v => "20120813"}.merge!(params)

      render :json => perform_graph_request("checkins/#{@checkin_id}/reply", params, "post", oauth_token)
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
