class UserController < ApplicationController
#respond_to :json

    def register
        @foursquare_id = params['foursquare_id']
        @device_id = params['device_token']
        @first_name = params['first_name']
        @last_name = params['last_name']
    
        if @foursquare_id and @device_id and @first_name and @last_name
            @device=APN::Device.find_by_token(@device_id)
            if @device.nil?
                @device = APN::Device.create(:token => @device_id)
                # maybe send a notification about a new device
            else
                Rails.logger.info("yo, device exists" + @device.inspect)
            end

            @user = User.find_by_device_token_and_foursquare_id(@device.token, @foursquare_id)
            if @user.nil?
                @user = User.create(:device_token => @device.token, 
                                    :foursquare_id => @foursquare_id,
                                    :first_name => @first_name,
                                    :last_name => @last_name
                                   )
                                   Rails.logger.info("oh snap, new user: send push")
                                   #send_push(@device, "Welcome to Tumbleweed " + @user.first_name) 
                                   render :json => @user                                
            else
                Rails.logger.info("yo, user exists" + @user.inspect)
                #@user = User.show(@user.id)
                render :json => @user
            end

            #render :text => "i'm in register" 
        else
            render :text => "yo, pass in the variable foo" 
        end

    end


    def status
        render :text => "i'm in register"
    end

    protected
    def send_push(device, message)
        notification=APN::Notification.new
        notification.device=device
        notification.badge=1
        notification.sound=true
        notification.alert=message
        notification.save
        Rails.logger.info("saved notification")
    end
end
