class TestController < ApplicationController
  def createapn
  	user = User.last
  	message = "hello world"
  	device = user.device_token
  	user.send_push(device, message)
  	render :text => "ok"
  end
end
