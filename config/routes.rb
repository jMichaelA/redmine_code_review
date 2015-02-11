# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

match 'projects/:id/reviews', :to => 'reviews#index', :via => 'get'
match 'projects/:id/reviews/new', :to => 'reviews#new', :via => 'get'
match 'projects/:id/reviews/:review', :to => 'reviews#show', :via => 'get'

# TODO: (jchristensen)Something like this for the 'Create review' link on the revision page
#post 'post/:reviews/create', :to => 'reviews#create'
