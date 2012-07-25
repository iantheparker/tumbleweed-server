class UserController < ApplicationController

    def register
        @foursquare_id = params['foursquare_id']
        @device_id = params['device_token']
        @first_name = params['first_name']
        @last_name = params['last_name']
        Rails.logger.info(@user_name)

        @device=APN::Device.find_by_token(@device_id)
        if @device.nil?
            @device = APN::Device.create(:token => @device_id)
            # maybe send a notification about a new device
            # send our welcome push
            Rails.logger.info("oh snap, new device")
        else
            Rails.logger.info("yo, device exists" + @device.inspect)
        end

        @user = User.find_by_device_token_and_foursquare_id(@device.token, @foursquare_id)
        if @user.nil?
            @user = User.create(:device_token => @device.token, 
                    :foursquare_id => @foursquare_id
                    :first_name => @first_name,
                    :last_name => @last_name
            )
            Rails.logger.info("oh snap, new user")
            # maybe send a welcome here
        else
            Rails.logger.info("yo, user exists" + @user.inspect)
        end

        render :text => "i'm in register" 
    end


    def status
        render :text => "i'm in register"
    end
end
