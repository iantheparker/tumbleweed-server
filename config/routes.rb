TumbleweedServer::Application.routes.draw do

    match '/foursquare/push' => "foursquare#push"
    match '/register' => "user#register"
    match '/updater' => "user#update_from_app"
    # rails autogenerated routes for scaffolding
    # TODO restrict access to admin functions, add admin flag to users
    resources :users do
    	resources :checkins
    end

    resources :raw_checkins

end
