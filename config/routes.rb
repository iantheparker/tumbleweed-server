TumbleweedServer::Application.routes.draw do

    match '/foursquare/push' => "foursquare#push"
    match '/register' => "user#register"

    # rails autogenerated routes for scaffolding
    # TODO restrict access to admin functions, add admin flag to users
    resources :users

    resources :checkins
    resources :venues
    resources :raw_checkins


end
