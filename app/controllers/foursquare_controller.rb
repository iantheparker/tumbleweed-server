class FoursquareController < ApplicationController

    def push
        # first just log the raw checkin from foursquare
        raw_checkin = RawCheckin.create(:payload => params['checkin'])

        checkin = JSON.parse(params['checkin'])

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
