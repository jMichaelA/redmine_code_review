class ReviewsController < ApplicationController
  unloadable

  layout 'base'
  before_filter :find_project # TODO (jchristensen) Add before_filter :authorize when ready
  menu_item :redmine_code_review


  helper :watchers
  include WatchersHelper
  helper RepositoriesHelper
  helper ReviewHelper
  include ReviewQueriesHelper
  helper :review_queries
  include SortHelper
  helper :sort


  def index
    #@reviews = Review.where('project_id = ?', @project.id)
    #@review_column_names = ['#', 'Revision','Description', 'Submitted By', 'Due Date',
    #                        'Priority', 'Created On', 'Updated', 'Closed']
    retrieve_query
    sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    @query.sort_criteria = sort_criteria.to_a

    if @query.valid?
      case params[:format]
        when 'csv', 'pdf'
          @limit = Setting.reviews_export_limit.to_i
          if params[:columns] == 'all'
            @query.column_names = @query.available_inline_columns.map(&:name)
          end
        when 'atom'
          @limit = Setting.feeds_limit.to_i
        when 'xml', 'json'
          @offset, @limit = api_offset_and_limit
          @query.column_names = %w(author)
        else
          @limit = per_page_option
      end

      @review_count = @query.review_count
      @review_pages = Paginator.new @review_count, @limit, params['page']
      @offset ||= @review_pages.offset
      @review = @query.reviews(:include => [:priority],
                              :order => sort_clause,
                              :offset => @offset,
                              :limit => @limit)
      @review_count_by_group = @query.review_count_by_group

      respond_to do |format|
        format.html { render :template => 'reviews/index', :layout => !request.xhr? }
        format.api  {
          Review.load_visible_relations(@reviews) if include_in_api_response?('relations')
        }
        format.atom { render_feed(@reviews, :title => "#{@project || Setting.app_title}: #{l(:label_reviews_plural)}") }
        format.csv  { send_data(query_to_csv(@reviews, @query, params), :type => 'text/csv; header=present', :filename => 'reviews.csv') }
        format.pdf  { send_data(reviews_to_pdf(@reviews, @project, @query), :type => 'application/pdf', :filename => 'reviews.pdf') }
      end
    else
      respond_to do |format|
        format.html { render(:template => 'reviews/index', :layout => !request.xhr?) }
        format.any(:atom, :csv, :pdf) { render(:nothing => true) }
        format.api { render_validation_errors(@query) }
      end
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def show
    @review = Review.find(params[:review_id])
    @changeset = Changeset.find(@review.changeset_id)
    @repository = Repository.find(@changeset.repository_id)
    @available_watchers = @review.watcher_users

    if params[:file_id]
      review_diff
    end

  end

  def new # called when the page new is rendered
    @changeset = Changeset.find(params[:rev])
    @repository = Repository.find(@changeset.repository_id)
    # TODO: update this to use the specified permissions (currently gets all involved with the project)
    @possible_approvers = Member.find_all_by_project_id(@repository.project_id).uniq
    # Use this foreach to strip out potential approvers that don't have appropriate permissions
    #@possible_approvers.each do |approver|
    #  if approver.
    #end
    @possible_watchers = Member.find_all_by_project_id(@repository.project_id).uniq
  end

  def create_review
    @review = Review.create(:changeset_id => params[:changeset_id], :project_id => @project.id, :user_id => params[:user_id], :priority_id => params[:review_priority_id])
    # create review files

    @changefiles = Change.where("changeset_id = ?", @review.changeset_id)

    @changefiles.each do |file|
      ReviewFile.create(:review_id => @review.id, :change_id => file.id)
    end

    redirect_to review_path(:id => @project.id, :review_id => @review.id) # review that was just created
  end

  def add_user

  end

  def remove_user
    user = params[:user_id]
    review = params[:review_id]
    type = params[:type]

    rp = ReviewParticipant.where("user_id = 5 AND review_id = 1").take

    id = params[:id]
  end

  # TODO Uncomment and implement these when needed
  # def add_comment
  # end
  #
  # def delete_comment
  # end
  #
  # def approve
  # end
  #
  # def reject
  # end

private
  def review_diff
    # Check that this file belongs to this review
    @file = ReviewFile.get_by_review_and_file_id(params[:review_id], params[:file_id])
    comments = @file.review_comments

    if @file == nil
      review_show_error_not_found("This file is not part of this review") unless @file
      return nil
    end
    @path = @file.change.path
    @rev = @review.changeset.revision

    @diff_type = params[:type] || User.current.pref[:diff_type] || 'inline'
    @diff_type = 'inline' unless %w(inline sbs).include?(@diff_type)

    # Save diff type as user preference
    if User.current.logged? && @diff_type != User.current.pref[:diff_type]
      User.current.pref[:diff_type] = @diff_type
      User.current.preference.save
    end
    @cache_key = "reviews/show/#{@review.id}/" + Digest::MD5.hexdigest("#{@path}-#{@rev}-#{@diff_type}-#{current_language}")
    unless read_fragment(@cache_key)
      @diff = @repository.diff(@path, @rev, nil)
      review_show_error_not_found("Diff not found") unless @diff
    end

    @changeset = @repository.find_changeset_by_name(@rev)
    @diff_format_revisions = @repository.diff_format_revisions(@changeset, nil)
  end

  def find_project
    @project = Project.find(params[:id])
  end

  def review_show_error_not_found(message)
    render_error :message => message, :status => 404
  end

end
