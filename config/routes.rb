# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
post 'post/:revison/create', :to => 'reviews#create'
get '/code_review', :to => 'code_review#index'
