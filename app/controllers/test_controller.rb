class TestController < ApplicationController
  def createapn
  	user = User.first
  	message = "hello world"
  	device = APN::Device.find_by_token(user.device_token)
  	user.send_push(device, message)
  	render :text => "ok"
  end
end
