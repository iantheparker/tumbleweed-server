require 'net/http'

class FoursquareController < ApplicationController

    def push
        # first just log the raw checkin from foursquare
        raw_checkin = RawCheckin.create(:payload => params['checkin'])

        checkin = JSON.parse(params['checkin'])
        checkin_id = checkin["id"]
        checkin_reply(checkin_id)

        logger.info(checkin)
        logger.info(checkin_id)
        
        #devauth = "UT0L5SRHLHNCXFUNO3X4NKMIAFANLZBIWG13PA5F4N2L2F2M"
        #url = "https://api.foursquare.com/v2/checkins/"+checkin_id.to_s+"/reply"
        #uri = URI(url)
		#res = Net::HTTP.post_form(uri, 'oauth_token' => devauth, 'text' => 'Keep using Tumbleweed!')
		#puts res.body
		
		
 		
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
            device = APN::Device.find_by_token(user.device_token)
            message = "You checked in on foursquare at " + venue_name
            logger.info(message)
            send_push(device, message)
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
    
    def search
    	uri = URI.parse('https://api.foursquare.com/v2/venues/search?oauth_token=UT0L5SRHLHNCXFUNO3X4NKMIAFANLZBIWG13PA5F4N2L2F2M&ll=47.623055,-122.322345&limit=5&v=20120813') 
 		#logger.info(uri)
		http = Net::HTTP.new(uri.host, uri.port)
 		http.use_ssl = true
 		http.verify_mode = OpenSSL::SSL::VERIFY_NONE
 
 		request = Net::HTTP::Get.new(uri.request_uri)
 		#request.basic_auth 'email', 'password'
 
 		response = http.request(request)
 		puts response

		render :json => response.body
		#print response.body
		
    end
    
    def checkin_reply
    	#uri = URI.parse('https://api.foursquare.com/v2/checkins/add?oauth_token=UT0L5SRHLHNCXFUNO3X4NKMIAFANLZBIWG13PA5F4N2L2F2M&venueId=449a8388f964a52098341fe3&broadcast=private&v=20120813')
    	@checkin_id = "5029a860e4b0f6fce2e97f2d" 
    		
    	
    	params = {:text => "Tumbleweed rules!",
                :url => "http://tumbleweed.me"}

    	query_string = "?"
      	query_string += "oauth_token=UT0L5SRHLHNCXFUNO3X4NKMIAFANLZBIWG13PA5F4N2L2F2M"
    	
    	url = URI.parse("https://api.foursquare.com/v2/checkins/#{@checkin_id}/reply#{query_string}")
        request = Net::HTTP::Post.new("#{url.path}?#{url.query}",{"Content-Type"=>"text/json"})
        request.set_form_data(params)
      
      	http = Net::HTTP.new(url.host, url.port)
      	http.use_ssl = true
      	response = JSON.parse(http.start {|http| http.request(request)}.body)
      	response
      	render :json => response
    end
    
    def checkin
    	#uri = URI.parse('https://api.foursquare.com/v2/checkins/add?oauth_token=UT0L5SRHLHNCXFUNO3X4NKMIAFANLZBIWG13PA5F4N2L2F2M&venueId=449a8388f964a52098341fe3&broadcast=private&v=20120813')
    	params = {:venueId => "449a8388f964a52098341fe3",
                :broadcast => "private"}

    	query_string = "?"
      	query_string += "oauth_token=UT0L5SRHLHNCXFUNO3X4NKMIAFANLZBIWG13PA5F4N2L2F2M"
    	
    	url = URI.parse("https://api.foursquare.com/v2/checkins/add#{query_string}")
        request = Net::HTTP::Post.new("#{url.path}?#{url.query}",{"Content-Type"=>"text/json"})
        request.set_form_data(params)
      
      	http = Net::HTTP.new(url.host, url.port)
      	http.use_ssl = true
      	response = JSON.parse(http.start {|http| http.request(request)}.body)
      	response
      	render :json => response
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
