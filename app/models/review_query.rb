class ReviewQuery < Query

  self.queried_class = Review


  self.available_columns= [
      QueryColumn.new(:id, :sortable => "#{Review.table_name}.id", :default_order => 'desc', :caption => '#', :frozen => true),
      QueryColumn.new(:revision, :sortable => "#{Changeset.table_name}.revision", :groupable => true),
      QueryColumn.new(:subject, :sortable => "#{Changeset.table_name}.comments", :inline => true, :frozen => true),
      QueryColumn.new(:requester, :sortable => "#{User.table_name}.name", :groupable => true),
      QueryColumn.new(:project, :sortable => "#{Project.table_name}.name", :groupable => true),
      QueryColumn.new(:priority, :sortable => "#{IssuePriority.table_name}.position", :default_order => 'desc', :groupable => true, :frozen => true),
      QueryColumn.new(:created_on, :sortable => "#{Review.table_name}.created_on", :groupable => true, :frozen => true),
      QueryColumn.new(:due_date, :sortable => "#{Review.table_name}.due_date", :frozen => true),
      QueryColumn.new(:updated_on, :sortable => "#{Review.table_name}.updated_on", :groupable => true),
      QueryColumn.new(:closed, :sotrable => "#{Review.table_name}.closed", :groupable => true)
  ]

  def initialize_available_filters

    principals = []
    subprojects = []
    versions = []



    if project
      principals += project.principals.sort
      unless project.leaf?
        subprojects = project.descendants.visible.all
        principals += Principal.member_of(subprojects)
      end
    else
      if all_projects.any?
        principals += Principal.member_of(all_projects)
      end
    end
    principals.uniq!
    principals.sort!
    principals.reject! {|p| p.is_a?(GroupBuiltin)}
    users = principals.select {|p| p.is_a?(User)}

    if project.nil?
      project_values = []
      if User.current.logged? && User.current.memberships.any?
        project_values << ["<< #{l(:label_my_projects).downcase} >>", "mine"]
      end
      project_values += all_projects_values
      add_available_filter("project_id",
                           :type => :list, :values => project_values
      ) unless project_values.empty?
    end

    author_values = []
    author_values << ["<< #{l(:label_me)} >>", "me"] if User.current.logged?
    author_values += users.collect{|s| [s.name, s.id.to_s] }
    add_available_filter("requester_id",
                         :type => :list, :values => author_values
    ) unless author_values.empty?

    add_available_filter "subject", :type => :text
    add_available_filter "created_on", :type => :date_past
    add_available_filter "updated_on", :type => :date_past
    add_available_filter "closed_on", :type => :date_past
    add_available_filter "start_date", :type => :date
    add_available_filter "due_date", :type => :date
    add_available_filter "estimated_hours", :type => :float
    add_available_filter "done_ratio", :type => :integer
  end

  def review_count
    Review.joins(:changeset, :project).where(statement).count
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

  def review_count_by_group
    r = nil
    if grouped?
      begin
        # Rails3 will raise an (unexpected) RecordNotFound if there's only a nil group value
        r = Review.visible.
            joins(:changeset, :project).
            where(statement).
            joins(joins_for_order_statement(group_by_statement)).
            group(group_by_statement).
            count
      rescue ActiveRecord::RecordNotFound
        r = {nil => issue_count}
      end
      c = group_by_column
    end
    r
  rescue ::ActiveRecord::StatementInvalid => e
    raise StatementInvalid.new(e.message)
  end

  def reviews(options={})
    order_option = [group_by_sort_order, options[:order]].flatten.reject(&:blank?)

    scope = Review.visible.
        joins(:changeset, :project).
        includes(([:changeset, :project] + (options[:include] || [])).uniq).
        where(options[:conditions]).
        limit(options[:limit]).
        offset(options[:offset])

    scope.all


  end


end