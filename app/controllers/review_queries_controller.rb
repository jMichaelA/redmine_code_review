
class ReviewsQueriesController < ApplicationController
  menu_item :Reviews
  before_filter :find_query, :except => [:new, :create, :index]
  before_filter :find_optional_project, :only => [:new, :create]

  accept_api_auth :index

  def index
    case params[:format]
      when 'xml', 'json'
        @offset, @limit = api_offset_and_limit
      else
        @limit = per_page_option
    end
    @query_count = ReviewQuery.visible.count
    @query_pages = Paginator.new @query_count, @limit, params['page']
    @queries = ReviewQuery.visible.
        order("#{Query.table_name}.name").
        limit(@limit).
        offset(@offset).
        all
    respond_to do |format|
      format.api
    end
  end

  def new
    @query = ReviewQuery.new
    @query.user = User.current
    @query.project = @project
    @query.visibility = ReviewQuery::VISIBILITY_PRIVATE unless User.current.allowed_to?(:manage_public_queries, @project) || User.current.admin?
    @query.build_from_params(params)
  end

  def create
    @query = ReviewQuery.new(params[:query])
    @query.user = User.current
    @query.project = params[:query_is_for_all] ? nil : @project
    @query.visibility = ReviewQuery::VISIBILITY_PRIVATE unless User.current.allowed_to?(:manage_public_queries, @project) || User.current.admin?
    @query.build_from_params(params)
    @query.column_names = nil if params[:default_columns]

    if @query.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to_reviews(:query_id => @query)
    else
      render :action => 'new', :layout => !request.xhr?
    end
  end

  def edit
  end

  def update
    @query.attributes = params[:query]
    @query.project = nil if params[:query_is_for_all]
    @query.visibility = ReviewQuery::VISIBILITY_PRIVATE unless User.current.allowed_to?(:manage_public_queries, @project) || User.current.admin?
    @query.build_from_params(params)
    @query.column_names = nil if params[:default_columns]

    if @query.save
      flash[:notice] = l(:notice_successful_update)
      redirect_to_reviews(:query_id => @query)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @query.destroy
    redirect_to_reviews(:set_filter => 1)
  end

  private
  def find_query
    @query = ReviewQuery.find(params[:id])
    @project = @query.project
    render_403 unless @query.editable_by?(User.current)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_optional_project
    @project = Project.find(params[:project_id]) if params[:project_id]
    render_403 unless User.current.allowed_to?(:save_queries, @project, :global => true)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def redirect_to_reviews(options)
    if params[:gantt]
      if @project
        redirect_to project_gantt_path(@project, options)
      end
    else
      redirect_to _project_reviews_path(@project, options)
    end
  end
end
