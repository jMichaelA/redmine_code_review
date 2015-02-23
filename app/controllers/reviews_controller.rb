class ReviewsController < ApplicationController
  unloadable

  layout 'base'
  before_filter :find_project # TODO (jchristensen) Add before_filter :authorize when ready
  menu_item :redmine_code_review

  helper :watchers
  include WatchersHelper
  helper RepositoriesHelper
  helper ReviewHelper

  def index
    @reviews = Review.where('project_id = ?', @project.id)
    @review_column_names = ['#', 'Revision','Description', 'Submitted By', 'Due Date',
                            'Priority', 'Created On', 'Updated', 'Closed']
  end

  def show
    @review = Review.find(params[:review_id])
    @changeset = Changeset.find(@review.changeset_id)
    @repository = Repository.find(@changeset.repository_id)

    if params[:file_id]
      review_diff
    end

  end

  def new

  end

  def create_review
    @review = Review.create(:changeset_id => params[:changeset_id], :project_id => @project.id, :user_id => params[:user_id], :priority_id => '2')
    # create review files

    @changefiles = Change.where("changeset_id = ?", @review.changeset_id)

    @changefiles.each do |file|
      ReviewFile.create(:review_id => @review.id, :change_id => file.id)
    end

    redirect_to review_path(:id => @project.id, :review_id => @review.id) # review that was just created
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
