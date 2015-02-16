# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
#post 'post/:revision/create', :to => 'reviews#create'
#get '/code_review', :to => 'code_review#index'

#match 'projects/:id/reviews', :to => 'reviews#index', :via => 'get'
#match 'projects/:id/reviews/new', :to => 'reviews#new', :via => 'get'
#match 'projects/:id/reviews/:review_id', :to => 'reviews#show', :via => 'get'

get 'projects/:id/reviews', :to => 'reviews#index'
get 'projects/:id/reviews/new', :to => 'reviews#new'
get 'projects/:id/reviews/:review_id', :to => 'reviews#show', :as => 'review'



# TODO: (jchristensen)Something like this for the 'Create review' link on the revision page
#post 'post/:reviews/create', :to => 'reviews#create'
