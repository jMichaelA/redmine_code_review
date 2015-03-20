# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
#post 'post/:revision/create', :to => 'reviews#create'
#get '/code_review', :to => 'code_review#index'


#match 'projects/:id/reviews', :to => 'reviews#index', :via => 'get'
#match 'projects/:id/reviews/new', :to => 'reviews#new', :via => 'get'
#match 'projects/:id/reviews/:review_id', :to => 'reviews#show', :via => 'get'

get 'projects/:id/reviews', :to => 'reviews#index'
get 'projects/:id/reviews/new', :to => 'reviews#new', :as => 'new'
get 'projects/:id/reviews/:review_id', :to => 'reviews#show', :as => 'review'


get 'reviews/:review_id/:user_id', :to => 'reviews#remove_user'

post 'participants/watch', :to => 'participants#watch', :as => 'participate'
delete 'participants/watch', :to => 'participants#unwatch'
get 'participants/new', :to => 'participants#new'
post 'participants', :to => 'participants#create'
post 'participants/append', :to => 'participants#append'
delete 'participants', :to => 'participants#destroy'
get 'participants/autocomplete_for_user', :to => 'participants#autocomplete_for_user'
# Specific routes for issue watchers API
#post 'issues/:object_id/watchers', :to => 'watchers#create', :object_type => 'issue'
#delete 'issues/:object_id/watchers/:user_id' => 'watchers#destroy', :object_type => 'issue'


# TODO: (jchristensen)Something like this for the 'Create review' link on the revision page
post 'reviews/create_review', :to => 'reviews#create_review'
