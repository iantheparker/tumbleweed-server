class User < ActiveRecord::Base
	has_many :checkins, :dependent => :destroy
end
