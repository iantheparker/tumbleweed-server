class ApplicationController < ActionController::Base
  protect_from_forgery
=begin  
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
=end
end
