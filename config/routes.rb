# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'reviews', :to => 'reviews#index'
get 'reviews/new', :to => 'reviews#new'
get 'reviews/:id', :to => 'reviews#show'

# TODO: (jchristensen)Something like this for the 'Create review' link on the revision page
#post 'post/:revison/create', :to => 'reviews#create'
