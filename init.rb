Redmine::Plugin.register :redmine_code_review do
  name 'Redmine Code Review'
  author 'Jacob Christensen, Riley Oakden, Jonathan Koyle, and Jordan Devenport'
  description 'Code review plugin for Redmine'
  version '0.0.1'
  url 'https://github.com/jak103/redmine_code_review'
  author_url ''

  project_module :code_review do
    permission :view_reviews, :reviews => :index
  end

  menu :project_menu, :redmine_code_review, { :controller => 'reviews', :action => 'index'}, :caption => 'Code review', :before => :repository
end
