class UserController < ApplicationController

    def register
        @foursquare_id = params['foursquare_id']
        @device_id = params['device_token']
        Rails.logger.info(@device_id)
        Rails.logger.info(@foursquare_id)
        @device=APN::Device.find_or_create_by_token(:token => @device_id)
        Rails.logger.info(@device)
        @user = User.find_or_create_by_token_and_foursquare_id(@device.token, @foursquare_id)
        Rails.logger.info(@user)
        render :text => "i'm in register" 
    end


    def status
        render :text => "i'm in register"
    end
end
