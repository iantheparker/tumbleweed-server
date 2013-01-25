class UserController < ApplicationController
    skip_before_filter :verify_authenticity_token
    def register
        @foursquare_id = params['foursquare_id']
        @device_id = params['device_token']
        @first_name = params['first_name']
        @last_name = params['last_name']
        @oauth_token = params['oauth_token']
    	    	
        if @foursquare_id and @device_id and @first_name and @last_name
            @device=APN::Device.find_by_token(@device_id)
            if @device.nil?
                @device = APN::Device.create(:token => @device_id)
            else
                Rails.logger.info("yo, device exists" + @device.inspect)
            end

            @user = User.find_by_device_token_and_foursquare_id(@device.token, @foursquare_id)
            if @user.nil?
                @user = User.create(:device_token => @device.token, 
                                    :foursquare_id => @foursquare_id,
                                    :first_name => @first_name,
                                    :last_name => @last_name,
                                    :oauth_token => @oauth_token)
                                   Rails.logger.info("oh snap, new user: send push")
                                   @user.send_push(@device, "Welcome to No Man's Land. Class is now in session. " + @user.first_name) 
                                   render :json => @user                                
            else
                #if /#{@device_id}/.match(@user.device_token).nil?
                #	@device.update_attributes(:token => @device_id)
                #	@user.update_attributes(:device_token => @device.token)
                #end
                Rails.logger.info("yo, user exists, so resetting values")
                @user.checkins.destroy_all
                @user.level = 0
                @user.save
                render :json => @user
            end
        else
            render :text => "yo, pass in the variable foo" 
        end

    end

    def update_from_app
	@user_id = params['id']
	@level = params['level']
	
	#in case the server misses a foursquare push and the app knows it,
	#then it can update the user here
	
	user = User.find_by_id(@user_id)
	user.level = @level
	user.save
	
        render :json => user
    end
    
    #unlock distance method

end
