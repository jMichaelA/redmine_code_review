Redmine::Plugin.register :loupe do
  name 'Loupe: Redmine Code Review'
  author 'Jacob Christensen'
  description 'A loupe (pronounced loop) is a simple, small magnification device used to see small details more closely. Jewelers typically use a handheld loupe to magnify gemstones that they wish to inspect.'
  version '0.0.1'
  url ''
  author_url ''
  
  # This plugin adds a project module
  # It can be enabled/disabled at project level (Project settings -> Modules)
  project_module :loupe do
    # A public action
    permission :loupe_view_reviews, {:loupe => [:index]}, :public => true
  end
  
  # A new item is added to the project menu
  menu :project_menu, :loupe, { :controller => 'review', :action => 'index' }, :caption => 'Code Review', :after => :repository, :param => :project_id
  
  # Meetings are added to the activity view
  activity_provider :meetings
end
