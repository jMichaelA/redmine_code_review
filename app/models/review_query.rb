class ReviewQuery < Query

  self.queried_class = Review

  self.available_columns= [
      QueryColumn.new(:id, :sortable => "#{Review.table_name}.id", :default_order => 'desc', :caption => '#', :frozen => true),
      QueryColumn.new(:revision, :sortable => "#{Changeset.table_name}.revision", :groupable => true),
      QueryColumn.new(:description, :sortable => "#{Changeset.table_name}.comments"),
      QueryColumn.new(:requester, :sortable => "#{User.table_name}.name", :groupable => true),
      QueryColumn.new(:project, :sortable => "#{Project.table_name}.name", :groupable => true),
      QueryColumn.new(:due_date, :sortable => "#{Review.table_name}.due_date"),
      QueryColumn.new(:priority, :sortable => "#{IssuePriority.table_name}.position", :default_order => 'desc', :groupable => true),
      QueryColumn.new(:created_on, :sortable => "#{Review.table_name}.created_on", :groupable => true),
      QueryColumn.new(:updated_on, :sortable => "#{Review.table_name}.updated_on", :groupable => true),
      QueryColumn.new(:closed, :sotrable => "#{Review.table_name}.closed", :groupable => true)
  ]

end