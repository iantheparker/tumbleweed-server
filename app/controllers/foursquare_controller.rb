require 'ruby-bitly'

class FoursquareController < ApplicationController

    def push
      # first just log the raw checkin from foursquare
      raw_checkin = RawCheckin.create(:payload => params['checkin'])

      checkin = JSON.parse(params['checkin'])
      logger.info(checkin)
      venue = checkin["venue"]
      venue_id = venue["id"]
      venue_name = venue["name"]
      contact = venue["contact"]

      foursquare_user= JSON.parse(params['user'])
      foursquare_user_id = foursquare_user["id"]

      v = Venue.find_by_foursquare_id(venue_id)
      if v.nil?
        if contact.nil?
          v = Venue.create(:foursquare_id => venue_id, :name => venue_name)
        else
          phone = contact["phone"]
          twitter = contact["twitter"]
          v = Venue.create(:foursquare_id => venue_id, :name => venue_name, :admin_phone => phone, :admin_twitter => twitter)
        end
      end

      # TODO match up foursquare id to user's mobile device id (UDID?)
      #checkin = Checkin.create(:venue_id => v.id, :user_id => user.id)

      render :text => "got push"
    end

end
