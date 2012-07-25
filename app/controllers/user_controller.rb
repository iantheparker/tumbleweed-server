class UserController < ApplicationController

    def register
        @foursquare_id = params['foursquare_id']
        @device_id = params['device_token']
        @user_name = params['user_name']
        Rails.logger.info(@user_name)

        @device=APN::Device.find_by_token(:token => @device_id)
        if @device.nil?
            @device = APN::Device.create(:token => @device_id)
            # send our welcome push
        else
            # do other shit
            Rails.logger.info("yo, device exists" + @device.inspect)
        end

        @user = User.find_or_create_by_device_token_and_foursquare_id(@device.token, @foursquare_id)
        Rails.logger.info(@user)
        render :text => "i'm in register" 
    end


    def status
        render :text => "i'm in register"
    end
end
